class QDL::Wrap
  def self.wrapped?(klass, meth)
    QDL::Util.method_defined?(klass, wrapped_name(klass, meth))
  end

  def self.resolve_alias(klass, meth)
    klass = klass.to_s
    meth = meth.to_sym
    while QDL::Globals.aliases[klass] && QDL::Globals.aliases[klass][meth]
      if QDL::Globals.info.has_any?(klass, meth, [:pre, :post, :type])
        raise RuntimeError, "Alias #{QDL::Util.pp_klass_method(klass, meth)} has contracts. Contracts are only allowed on methods, not aliases."
      end
      meth = QDL::Globals.aliases[klass][meth]
    end
    return meth
  end

  def self.get_type_params(klass)
    klass = klass.to_s
    QDL::Globals.type_params[klass]
  end

  # [+klass+] may be a Class, String, or Symbol
  # [+meth+] may be a String or Symbol
  #
  # Wraps klass#method to check contracts and types. Does not rewrap
  # if already wrapped. Also records source location of method.
  def self.wrap(klass_str, meth)
    QDL::Globals.wrap_switch.off {
      klass_str = klass_str.to_s
      klass = QDL::Util.to_class klass_str
      # the_meth = klass.instance_method(meth)
      return if wrapped? klass, meth
      return if QDL::Config.instance.nowrap.member? klass_str.to_sym
      raise ArgumentError, "Attempt to wrap #{QDL::Util.pp_klass_method(klass, meth)}" if klass.to_s =~ /^QDL::/
      meth_old = wrapped_name(klass, meth) # meth_old is a symbol
      # return if (klass.method_defined? meth_old) # now checked above by wrapped? call
      is_singleton_method = QDL::Util.has_singleton_marker(klass_str)
      full_method_name = QDL::Util.pp_klass_method(klass_str, meth)
      klass_str_without_singleton = if is_singleton_method then QDL::Util.remove_singleton_marker(klass_str) else klass_str end

      klass.class_eval <<-RUBY, __FILE__, __LINE__
        alias_method meth_old, meth
        def #{meth}(*args, &blk)
          klass = "#{klass_str}"
          meth = types = matches = nil
	        bind = binding
          inst = nil

          QDL::Globals.wrap_switch.off {
            QDL::Globals.wrapped_calls["#{full_method_name}"] += 1 if QDL::Config.instance.gather_stats
            inst = nil
            inst = @__qdl_type.to_inst if ((defined? @__qdl_type) && @__qdl_type.is_a?(QDL::Type::GenericType))
            inst = Hash[QDL::Globals.type_params[klass][0].zip []] if (not(inst) && QDL::Globals.type_params[klass])
            inst = {} if not inst
            #{if not(is_singleton_method) then "inst[:self] = QDL::Type::NominalType.new(self.class)" end}
#            puts "Intercepted #{full_method_name}(\#{args.join(", ")}) { \#{blk} }, inst = \#{inst.inspect}"
            meth = QDL::Wrap.resolve_alias(klass, #{meth.inspect})
            QDL::Typecheck.typecheck(klass, meth) if QDL::Globals.info.get(klass, meth, :typecheck) == :call
            pres = QDL::Globals.info.get(klass, meth, :pre)
            QDL::Contract::AndContract.check_array(pres, self, *args, &blk) if pres
            types = QDL::Globals.info.get(klass, meth, :type)
            if types
              matches, args, blk, bind = QDL::Type::MethodType.check_arg_types("#{full_method_name}", self, bind, types, inst, *args, &blk)
            end
          }
	        ret = send(#{meth_old.inspect}, *args, &blk)
          QDL::Globals.wrap_switch.off {
            posts = QDL::Globals.info.get(klass, meth, :post)
            QDL::Contract::AndContract.check_array(posts, self, ret, *args, &blk) if posts
            if matches
              if meth.to_sym == :initialize
                types.each { |t|
                  raise ArgumentError, "Initialize method must be annotated with return type `self` or a generic type where base is `self`. #{full_method_name} has incorrect type." unless ((t.ret.is_a?(QDL::Type::VarType) && t.ret.name == :self) || (t.ret.is_a?(QDL::Type::GenericType) && t.ret.base.is_a?(QDL::Type::VarType) && t.ret.base.name == :self))
                }
              else
                ret = QDL::Type::MethodType.check_ret_types(self, "#{full_method_name}", types, inst, matches, ret, bind, *args, &blk) unless (meth.to_sym == :initialize)
              end
            end
            if QDL::Config.instance.guess_types.include?("#{klass_str_without_singleton}".to_sym) || QDL::Config.instance.get_types.include?([klass.to_s, meth])
            #puts "adding to otypes!"
              QDL::Globals.info.add(klass, meth, :otype, { args: (args.map { |arg| QDL::Wrap.val_to_type(arg) }), ret: QDL::Wrap.val_to_type(ret), block: block_given? })
            end
            return ret
          }
        end
        if (public_method_defined? meth_old) then public meth
        elsif (protected_method_defined? meth_old) then protected meth
        elsif (private_method_defined? meth_old) then private meth
        end
RUBY
    }
  end

  # [+default_class+] should be a class
  # [+name+] is the name to give the block as a contract
  def self.process_pre_post_args(default_class, name, *args, &blk)
    klass = slf = meth = contract = nil
    default_class = "Object" if (default_class.is_a? Object) && (default_class.to_s == "main") # special case for main
    if args.size == 3
      klass = class_to_string args[0]
      slf, meth = meth_to_sym args[1]
      contract = args[2]
    elsif args.size == 2 && blk
      klass = class_to_string args[0]
      slf, meth = meth_to_sym args[1]
      contract = QDL::Contract::FlatContract.new(name, &blk)
    elsif args.size == 2
      klass = default_class.to_s
      slf, meth = meth_to_sym args[0]
      contract = args[1]
    elsif args.size == 1 && blk
      klass = default_class.to_s
      slf, meth = meth_to_sym args[0]
      contract = QDL::Contract::FlatContract.new(name, &blk)
    elsif args.size == 1
      klass = default_class.to_s
      contract = args[0]
    elsif blk
      klass = default_class.to_s
      contract = QDL::Contract::FlatContract.new(name, &blk)
    else
      raise ArgumentError, "Invalid arguments to `pre` or `post`"
    end
    raise ArgumentError, "#{contract.class} received where Contract expected" unless contract.class < QDL::Contract::Contract
#    meth = :initialize if meth && meth.to_sym == :new  # actually wrap constructor
    klass = QDL::Util.add_singleton_marker(klass) if slf # && (meth != :initialize)
    return [klass, meth, contract]
  end

  # [+default_class+] should be a class
  def self.process_type_args(default_class, *args)
    klass = meth = type = nil
    default_class = "Object" if (default_class.is_a? Object) && (default_class.to_s == "main") # special case for main
    if args.size == 3
      klass = class_to_string args[0]
      slf, meth = meth_to_sym args[1]
      type = type_to_type args[2]
    elsif args.size == 2
      klass = default_class.to_s
      slf, meth = meth_to_sym args[0]
      type = type_to_type args[1]
    elsif args.size == 1
      klass = default_class.to_s
      type = type_to_type args[0]
    else
      raise ArgumentError, "Invalid arguments to `type`"
    end
    raise ArgumentError, "Excepting method type, got #{type.class} instead" if type.class != QDL::Type::MethodType
#    meth = :initialize if meth && slf && meth.to_sym == :new  # actually wrap constructor
    klass = QDL::Util.add_singleton_marker(klass) if slf
    return [klass, meth, type]
  end

  def self.process_infer_args(default_class, *args)
    klass = meth = nil
    default_class = "Object" if (default_class.is_a? Object) && (default_class.to_s == "main") # special case for main
    if args.size == 2
      klass = class_to_string args[0]
      slf, meth = meth_to_sym args[1]
    elsif args.size == 1
      klass = default_class.to_s
      slf, meth = meth_to_sym args[0]
    elsif args.size == 0
      klass = default_class.to_s
    else
      raise ArgumentError, "Invalid arguments to `infer`"
    end
    klass = QDL::Util.add_singleton_marker(klass) if slf
    return [klass, meth]
  end

  private

  def self.wrapped_name(klass, meth)
    klass_str = QDL::Util.to_class_str(klass).hash
    "__qdl_#{meth.to_s}_old_#{klass_str}".to_sym
  end

  def self.unwrapped_name(klass, meth_str)
    if not meth_str.start_with?('__qdl_') and meth_str.include?('_old_')
      raise Exception, "cannot get unwrapped name for #{meth_str}"
    end
    klass_str = QDL::Util.to_class_str(klass).hash.to_s
    meth_str = meth_str.split("_#{klass_str}")[0]
    meth_str[6..-5]
  end

  def self.class_to_string(klass)
    case klass
    when Class, Module
      return klass.to_s
    when String
      return klass
    when Symbol
      return klass.to_s
    else
      raise ArgumentError, "#{klass.class} received where klass (Class, Symbol, or String) expected"
    end
  end

  def self.meth_to_sym(meth)
    raise ArgumentError, "#{meth.class} received where method (Symbol or String) expected" unless meth.class == String || meth.class == Symbol
    meth = meth.to_s
    meth =~ /^(.*\.)?(.*)$/
    raise RuntimeError, "Only self.method allowed" if $1 && $1 != "self."
    return [$1, $2.to_sym]
  end

  def self.type_to_type(type)
    case type
    when QDL::Type::Type
      return type
    when String
      return QDL::Globals.parser.scan_str type
    end
  end

  def self.val_to_type(val)
    case val
    when TrueClass, FalseClass, NilClass
      QDL::Type::SingletonType.new(val)
    when Array
      typs = []
      val.each { |t| typs << val_to_type(t) }
      param = QDL::Type::UnionType.new(*typs).canonical
      QDL::Type::GenericType.new(QDL::Globals.types[:array], param)
    when Hash
      key_typs = []
      val_typs = []
      val.each_key { |k| key_typs << val_to_type(k) }
      val.each_value { |v| val_typs << val_to_type(v) }
      key_param = QDL::Type::UnionType.new(*key_typs).canonical
      val_param = QDL::Type::UnionType.new(*val_typs).canonical
      QDL::Type::GenericType.new(QDL::Globals.types[:hash], key_param, val_param)
    else
      QDL::Type::NominalType.new(val.class)
    end
  end

  # called by Object#method_added (sing=false) and Object#singleton_method_added (sing=true)
  def self.do_method_added(the_self, sing, klass, meth)
    if sing
      loc = the_self.singleton_method(meth).source_location
    else
      loc = the_self.instance_method(meth).source_location
    end
    QDL::Logging.log :wrap, :trace, "[#{loc && loc[0] || '??'}] Method #{klass}##{meth} added"
    QDL::Globals.info.set(klass, meth, :source_location, loc)

    # Apply any deferred contracts and reset list

    if QDL::Globals.deferred.size > 0
      if sing
        loc = the_self.singleton_method(meth).source_location
      else
        loc = the_self.instance_method(meth).source_location
      end

      QDL::Globals.info.set(klass, meth, :source_location, loc)

      a = QDL::Globals.deferred
      QDL::Globals.deferred = [] # Reset before doing more work to avoid infinite recursion
      a.each { |prev_klass, kind, contract, h|
        if QDL::Util.has_singleton_marker(klass)
          tmp_klass = QDL::Util.remove_singleton_marker(klass)
        else
          tmp_klass = klass
        end
        if (!h[:class_check] && (prev_klass != tmp_klass)) || (h[:class_check] && (h[:class_check].to_s != tmp_klass))
          raise RuntimeError, "Deferred #{kind} contract from class #{prev_klass} being applied in class #{tmp_klass} to #{meth}"
        end
        QDL::Globals.info.add(klass, meth, kind, contract)
        QDL::Wrap.wrap(klass, meth) if h[:wrap]
        unless !h.has_key?(:typecheck) || QDL::Globals.info.set(klass, meth, :typecheck, h[:typecheck])
          raise RuntimeError, "Inconsistent typecheck flag on #{QDL::Util.pp_klass_method(klass, meth)}"
        end
        QDL::Typecheck.typecheck(klass, meth) if h[:typecheck] == :now
        if (h[:typecheck] && h[:typecheck] != :call)
          QDL::Globals.to_typecheck[h[:typecheck]] = Set.new unless QDL::Globals.to_typecheck[h[:typecheck]]
          QDL::Globals.to_typecheck[h[:typecheck]].add([klass, meth])
        end
        if kind == :infer
          if tag == :now
            QDL::Typecheck.infer(klass, meth)
          else
            QDL::Globals.to_infer[tag] = Set.new unless QDL::Globals.to_infer[tag]
            QDL::Globals.to_infer[tag].add([klass, meth])
          end
        end
      }
    elsif QDL::Globals.infer_added &&
      !(QDL::Globals.info.has_any?(klass, meth, [:typecheck, :infer]))
      # Tag this method to be added to to-be-inferred set if it doesn't already have a type, and as
      # long as it isn't marked as being skipped
      unless ((QDL::Util.has_singleton_marker(klass) &&
               QDL::Globals.no_infer_meths.include?([QDL::Util.remove_singleton_marker(klass).to_s, "self."+meth.to_s])) ||
              (QDL::Globals.no_infer_meths.include?([klass.to_s, meth.to_s])) ||
              (loc && QDL::Globals.infer_added_filter_dirs && !QDL::Globals.infer_added_filter_dirs.member?(loc[0])))
        QDL::Logging.log :wrap, :trace, "... Added"
        tag = QDL::Globals.infer_added
        QDL::Globals.to_infer[tag] = Set.new unless QDL::Globals.to_infer[tag]
        QDL::Globals.to_infer[tag].add([klass, meth])
      else
        QDL::Logging.log :wrap, :trace, "... Rejected"
      end
    end

    # Wrap method if there was a prior contract for it.
    if QDL::Globals.to_wrap.member? [klass, meth]
      QDL::Globals.to_wrap.delete [klass, meth]
      if sing
        loc = the_self.singleton_method(meth).source_location
      else
        loc = the_self.instance_method(meth).source_location
      end
      QDL::Globals.info.set(klass, meth, :source_location, loc)
      QDL::Wrap.wrap(klass, meth)
    end

    # Type check method if requested
    if QDL::Globals.to_typecheck[:now].member? [klass, meth]
      QDL::Globals.to_typecheck[:now].delete [klass, meth]
      QDL::Typecheck.typecheck(klass, meth)
    end

    if QDL::Config.instance.guess_types.include?(the_self.to_s.to_sym) && !QDL::Globals.info.has?(klass, meth, :type)
      # Added a method with no type annotation from a class we want to guess types for
      QDL::Wrap.wrap(klass, meth)
    end
    if QDL::Config.instance.get_types.include?([klass, meth])
      QDL.create_binding_meth(klass, meth)
      QDL::Wrap.wrap(klass, meth)
    end
  end
end

module QDL::Annotate
  # [+klass+] may be Class, Symbol, or String
  # [+method+] may be Symbol or String
  # [+contract+] must be a Contract
  # [+wrap+] indicates whether the contract should be enforced (true) or just recorded (false)
  # [+ version +] is a rubygems version requirement string (or array of such requirement strings)
  #    if the current Ruby version does not satisfy the version, the type call will be ignored
  #
  # Add a precondition to a method. Possible invocations:
  # pre(klass, meth, contract)
  # pre(klass, meth) { block } = pre(klass, meth, FlatContract.new { block })
  # pre(meth, contract) = pre(self, meth, contract)
  # pre(meth) { block } = pre(self, meth, FlatContract.new { block })
  # pre(contract) = pre(self, next method, contract)
  # pre { block } = pre(self, next method, FlatContract.new { block })
  def pre(*args, wrap: QDL::Config.instance.pre_defaults[:wrap], version: nil, &blk)
    return if version && !(Gem::Requirement.new(version).satisfied_by? Gem.ruby_version)
    klass, meth, contract = QDL::Wrap.process_pre_post_args(self, "Precondition", *args, &blk)
    if meth
      QDL::Globals.info.add(klass, meth, :pre, contract)
      if wrap
        if QDL::Util.method_defined?(klass, meth) || meth == :initialize # there is always an initialize
          QDL::Wrap.wrap(klass, meth)
        else
          QDL::Globals.to_wrap << [klass, meth]
        end
      end
    else
      QDL::Globals.deferred << [klass, :pre, contract, {wrap: wrap}]
    end
    nil
  end

  # Add a postcondition to a method. Same possible invocations as pre.
  def post(*args, wrap: QDL::Config.instance.post_defaults[:wrap], version: nil, &blk)
    return if version && !(Gem::Requirement.new(version).satisfied_by? Gem.ruby_version)
    klass, meth, contract = QDL::Wrap.process_pre_post_args(self, "Postcondition", *args, &blk)
    if meth
      QDL::Globals.info.add(klass, meth, :post, contract)
      if wrap
        if QDL::Util.method_defined?(klass, meth) || meth == :initialize
          QDL::Wrap.wrap(klass, meth)
        else
          QDL::Globals.to_wrap << [klass, meth]
        end
      end
    else
      QDL::Globals.deferred << [klass, :post, contract, {wrap: wrap}]
    end
    nil
  end

  # [+ klass +] may be Class, Symbol, or String
  # [+ method +] may be Symbol or String
  # [+ type +] may be Type or String
  # [+ wrap +] indicates whether the type should be enforced (true) or just recorded (false)
  # [+ typecheck +] indicates a method that should be statically type checked, as follows
  #    if :call, indicates method should be typechecked when called
  #    if :now, indicates method should be typechecked immediately
  #    if other-symbol, indicates method should be typechecked when qdl_do_typecheck(other-symbol) is called
  # [+ version +] is a rubygems version requirement string (or array of such requirement strings)
  #    if the current Ruby version does not satisfy the version, the type call will be ignored
  #
  # Set a method's type. Possible invocations:
  # type(klass, meth, type)
  # type(meth, type)
  # type(type)
  def type(*args, wrap: QDL::Config.instance.type_defaults[:wrap], typecheck: QDL::Config.instance.type_defaults[:typecheck], version: nil)
    return if version && !(Gem::Requirement.new(version).satisfied_by? Gem.ruby_version)
    klass, meth, type = begin
                          QDL::Wrap.process_type_args(self, *args)
                        rescue Racc::ParseError => err
                          # Remove enough backtrace to only include actual source line
                          # Warning: Adjust the -5 below if the code (or this comment) changes
                          bt = err.backtrace
                          bt.shift until bt[0] =~ /^#{__FILE__}:#{__LINE__-5}/
                          bt.shift # remove QDL::Globals.contract_switch.off call
                          bt.shift # remove type call itself
                          err.set_backtrace bt
                          raise err
                        end
    typs = type.args + [type.ret]
    if type.block
      block_type = type.block.is_a?(QDL::Type::OptionalType) ? type.block.type : type.block
      typs = typs + block_type.args + [block_type.ret]
    end
    QDL::Globals.dep_types << [klass, meth, type] if typs.any? { |t| t.is_a?(QDL::Type::ComputedType) || (t.is_a?(QDL::Type::BoundArgType) && t.type.is_a?(QDL::Type::ComputedType)) }
    if meth
# It turns out Ruby core/stdlib don't always follow this convention...
#        if (meth.to_s[-1] == "?") && (type.ret != QDL::Globals.types[:bool])
#          warn "#{QDL::Util.pp_klass_method(klass, meth)}: methods that end in ? should have return type %bool"
#        end
      QDL::Globals.info.add(klass, meth, :type, type)
      unless QDL::Globals.info.set(klass, meth, :typecheck, typecheck)
        raise RuntimeError, "Inconsistent typecheck flag on #{QDL::Util.pp_klass_method(klass, meth)}"
      end
      if wrap || typecheck
        if QDL::Util.method_defined?(klass, meth) || meth == :initialize
          QDL::Globals.info.set(klass, meth, :source_location, QDL::Util.to_class(klass).instance_method(meth).source_location)
          if typecheck == :now
            QDL::Typecheck.typecheck(klass, meth)
          elsif typecheck && (typecheck != :call)
            QDL::Globals.to_typecheck[typecheck] = Set.new unless QDL::Globals.to_typecheck[typecheck]
            QDL::Globals.to_typecheck[typecheck].add([klass, meth])
          end
          QDL::Wrap.wrap(klass, meth) if wrap
        else
          QDL::Globals.to_wrap << [klass, meth] if wrap
          if (typecheck && typecheck != :call)
            QDL::Globals.to_typecheck[typecheck] = Set.new unless QDL::Globals.to_typecheck[typecheck]
            QDL::Globals.to_typecheck[typecheck].add([klass, meth])
          end
        end
      end
    else
      QDL::Globals.deferred << [klass, :type, type, {wrap: wrap,
                                               typecheck: typecheck}]
    end
    nil
  end

  def orig_type(klass=self, meth, type, wrap: nil, typecheck: nil)
    $orig_types = true
    klass, meth, type = QDL::Wrap.process_type_args(self, klass, meth, type)
    QDL::Globals.info.add(klass, meth, :orig_type, type)
    if QDL::Util.method_defined?(klass, meth) #|| meth == :initialize
      QDL::Globals.info.set(klass, meth, :source_location, QDL::Util.to_class(klass).instance_method(meth).source_location)
    end
    $orig_type_list = [] unless $orig_type_list
    $orig_type_list << [klass, meth]
  end

  def orig_var_type(klass=self, var, type)
    raise RuntimeError, "Variable cannot begin with capital" if var.to_s =~ /^[A-Z]/
    return if var.to_s =~ /^[a-z]/ # local variables handled specially, inside type checker
    klass = QDL::Util::GLOBAL_NAME if var.to_s =~ /^\$/
    unless QDL::Globals.info.set(klass, var, :orig_type, QDL::Globals.parser.scan_str("#T #{type}"))
      raise RuntimeError, "Type already declared for #{var}"
    end
  end

  def readd_comp_types
    QDL::Globals.dep_types.each { |klass, meth, t| QDL::Globals.info.add(klass, meth, :type, t) unless meth.nil? }
  end

  # Very similar to `type`, but arguments are:
  # [+ klass +] may be Class, Symbol, or String
  # [+ method +] may be Symbol or String
  # [+ time +] indicates a method type that should be statically inferred at the given time, as follows
  #    if :now, indicates method type should be inferred immediately
  #    if other-symbol, indicates method type should be inferred when QDL.do_infer(other-symbol) is called
  # time is currently a *required* parameter
  # possible invocations:
  # infer(klass, meth, time: sym)
  # infer(meth, time: sym)
  # infer(time: sym)
  def infer(*args, time: QDL::Config.instance.infer_defaults[:time])
    ## TODO: do we want to handle the case that time is :call?
    raise RuntimeError, "Calls to `infer` must come with a specified time." if !time
    ## might remove the above error later.
    klass, meth = begin
                    QDL::Wrap.process_infer_args(self, *args)
                  rescue Racc::ParseError => err
                    # Remove enough backtrace to only include actual source line
                    # Warning: Adjust the -5 below if the code (or this comment) changes
                    bt = err.backtrace
                    bt.shift until bt[0] =~ /^#{__FILE__}:#{__LINE__-5}/
                    bt.shift # remove QDL::Globals.contract_switch.off call
                    bt.shift # remove type call itself
                    err.set_backtrace bt
                    raise err
                  end
    if meth
      unless QDL::Globals.info.set(klass, meth, :infer, time)
        raise RuntimeError, "Inconsistent infer time flag on #{QDL::Util.pp_klass_method(klass, meth)}"
      end
      if QDL::Util.method_defined?(klass, meth) #|| meth == :initialize
        QDL::Globals.info.set(klass, meth, :source_location, QDL::Util.to_class(klass).instance_method(meth).source_location)
        QDL::Typecheck.infer(klass, meth) if time == :now
      end
      QDL::Globals.to_infer[time] = Set.new unless QDL::Globals.to_infer[time]
      QDL::Globals.to_infer[time].add([klass, meth])
    else
      QDL::Globals.deferred << [klass, :infer, time, { }]

    end
    nil
  end

  # [+ path +] is a String pathname, for which all direct ".rb" subfiles will be inferred.
  def infer_all(path)
    path = Pathname.new(path).expand_path
    rb_files = Dir.entries(path).keep_if { |f| f.end_with?(".rb") }
    rb_files.each { |f| infer_file(path+f, more: true) }
    #QDL.do_infer :all
  end

  # [+ file +] is the String absolute path for a file, for which we want to infer all contained methods.
  # [+ more +] is a %bool indicating whether there are other methods outside given file to infer.
  #     When false, we infer after processing all methods in file. When true, we do not infer in this method.
  def infer_file(file, more: false)
    file = Pathname.new(file).expand_path.to_s
    return if QDL::Globals.no_infer_files.include? file
    index = ClassIndexer.process_file(file)
    index.each { |klass, meth_list|
      if QDL::Util.has_singleton_marker(klass)
        klass = QDL::Util.remove_singleton_marker(klass)
        meth_list.each { |meth|
          infer(klass, "self." + meth[:name], time: :files) unless QDL::Globals.no_infer_meths.include?([klass.to_s, "self."+meth[:name]])
        }
      else
        meth_list.each { |meth|
          infer klass, meth[:name], time: :files unless QDL::Globals.no_infer_meths.include?([klass.to_s, meth[:name].to_s])
        }
      end
    }
    #QDL.do_infer :all
  end

  def get_path_types(path, no_include = [])
    require 'pathname'
    path = ::Pathname.new(path).expand_path
    rb_files = Dir.entries(path).keep_if { |f| f.end_with?(".rb") }
    rb_files.each { |f| get_file_types(path+f) unless no_include.include?(f) }
  end

  def get_file_types(file)
    file = Pathname.new(file).expand_path.to_s
    puts "ABOUT TO INDEX FILE #{file}"
    index = ClassIndexer.process_file(file)
    index.each { |klass, meth_list|
      meth_list.each { |meth|
        meth = meth[:name].to_sym
        #QDL::Config.instance.get_types << [klass, meth]
        #QDL::Wrap.wrap(klass, meth) if QDL::Util.method_defined?(klass, meth)
        get_type(klass, meth)
      }
    }
  end

  def get_type(klass, meth)
    klass = klass.to_s
    meth = meth.to_sym
    QDL::Config.instance.get_types << [klass, meth]
    if QDL::Util.method_defined?(klass, meth)
      create_binding_meth(klass, meth)
      QDL::Wrap.wrap(klass, meth)
    end
  end

  def create_binding_meth(klass, meth)
    require 'method_source'
    klass = klass.to_s
    meth = meth.to_sym
    the_meth = QDL::Util.to_class(klass).instance_method(meth)
    new_meth_name = "QDL_#{klass}_#{(meth.hash + meth.to_s.hash).abs}".gsub("::", "__").gsub("[s]", "singleton_")
    return if QDL.singleton_class.method_defined? new_meth_name
    if !QDL.method_defined?(new_meth_name)
      ast = Parser::CurrentRuby.parse(the_meth.source) #QDL::Typecheck.get_ast(klass, meth)
      if (ast.type != :def) && (ast.type != :defs)
        ast = QDL::Typecheck.get_ast(klass, meth)
      end
      #args_expression = ast.children[1].loc.expression.source
      args_expression = ast.children[1].loc.expression
      args_string = args_expression ? args_expression.source : "" ## args_expression is nil if there are no arguments
      arg_vals = []
      the_meth.parameters.each { |kind, name|
        arg_vals << "#{name}: #{name}" if name
      }
      vals_hash = "{ " + arg_vals.join(",") + " }"
      meth_string = "def QDL.#{new_meth_name} #{args_string} \n #{vals_hash} \n end"
      QDL.class_eval meth_string
    end
  end

  def no_infer_meth(klass, meth)
    QDL::Globals.no_infer_meths << [klass.to_s, meth.to_s]
  end

  def no_infer_file(path)
    QDL::Globals.no_infer_files << Pathname.new(path).expand_path.to_s
  end

  # [+ klass +] is the class containing the variable; self if omitted; ignored for local and global variables
  # [+ var +] is a symbol or string containing the name of the variable
  # [+ typ +] is a string containing the type
  def var_type(klass=self, var, typ)
    raise RuntimeError, "Variable cannot begin with capital" if var.to_s =~ /^[A-Z]/
    return if var.to_s =~ /^[a-z]/ # local variables handled specially, inside type checker
    klass = QDL::Util::GLOBAL_NAME if var.to_s =~ /^\$/
    unless QDL::Globals.info.set(klass, var, :type, QDL::Globals.parser.scan_str("#T #{typ}"))
      raise RuntimeError, "Type already declared for #{var}"
    end
    nil
  end

  def infer_var_type(klass=self, var)
    raise RuntimeError, "Variable cannot begin with capital" if var.to_s =~ /^[A-Z]/
    return if var.to_s =~ /^[a-z]/ # local variables handled specially, inside type checker
    klass = QDL::Util::GLOBAL_NAME if var.to_s =~ /^\$/
    unless QDL::Globals.info.set(klass, var, :type, QDL::Type::VarType.new(cls: klass, name: var, category: :var))
      raise RuntimeError, "Type already declared for #{var}"
    end
    ## QDL::Globals.constrained_types includes the list of all types we want to perform constraint resolution/
    ## solution extract for. VarTypes in methods get added to this list after calling QDL.do_infer.
    ## Not sure when/where to add variable VarTypes so I'm doing it here.
    QDL::Globals.constrained_types << [klass, var]
    nil
  end

  # In the following three methods
  # [+ args +] is a sequence of symbol, typ. attr_reader is called for each symbol,
  # and var_type is called to assign the immediately following type to the
  # attribute named after that symbol.
  # Note these three methods are duplicated in QDLAnnotate
  def attr_accessor_type(*args)
    args.each_slice(2) { |name, typ|
      attr_accessor name
      var_type ("@" + name.to_s), typ
      type name, "() -> #{typ}"
      type name.to_s + "=", "(#{typ}) -> #{typ}"
    }
    nil
  end

  def attr_reader_type(*args)
    args.each_slice(2) { |name, typ|
      attr_reader name
      var_type ("@" + name.to_s), typ
      type name, "() -> #{typ}"
    }
    nil
  end

  alias_method :attr_type, :attr_reader_type

  def attr_writer_type(*args)
    args.each_slice(2) { |name, typ|
      attr_writer name
      var_type ("@" + name.to_s), typ
      type name.to_s + "=", "(#{typ}) -> #{typ}"
    }
    nil
  end

  def qdl_alias(klass=self, new_name, old_name)
    QDL.alias klass, new_name, old_name
  end

  # [+ klass +] is the class whose type parameters to set; self if omitted
  # [+params+] is an array of symbols or strings that are the
  # parameters of this (generic) type
  # [+variance+] is an array of the corresponding variances, :+ for
  # covariant, :- for contravariant, and :~ for invariant. If omitted,
  # all parameters are assumed to be invariant
  # [+all+] should be a symbol naming an all? method that behaves like Array#all?, and that accepts
  # a block that takes arguments in the same order as the type parameters
  # [+blk+] is for advanced use only. If present, [+all+] must be
  # nil. Whenever an instance of this class is instantiated!, the
  # block will be passed an array typs corresponding to the type
  # parameters of the class, and the block should return true if and
  # only if self is a member of self.class<typs>.
  def type_params(klass=self, params, all, variance: nil, &blk)
    raise RuntimeError, "Empty type parameters not allowed" if params.empty?
    klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
    klass = klass.to_s
    if QDL::Globals.type_params[klass]
      raise RuntimeError, "#{klass} already has type parameters #{QDL::Globals.type_params[klass]}"
    end
    params = params.map { |v|
      raise RuntimeError, "Type parameter #{v.inspect} is not symbol or string" unless v.class == String || v.class == Symbol
      v.to_sym
    }
    raise RuntimeError, "Duplicate type parameters not allowed" unless params.uniq.size == params.size
    raise RuntimeError, "Expecting #{params.size} variance annotations, got #{variance.size}" if variance && params.size != variance.size
    raise RuntimeError, "Only :+, +-, and :~ are allowed variance annotations" unless (not variance) || variance.all? { |v| [:+, :-, :~].member? v }
    raise RuntimeError, "Can't pass both all and a block" if all && blk
    raise RuntimeError, "all must be a symbol" unless (not all) || (all.instance_of? Symbol)
    chk = all || blk
    raise RuntimeError, "At least one of {all, blk} required" unless chk
    variance = params.map { |p| :~ } unless variance # default to invariant
    QDL::Globals.type_params[klass] = [params, variance, chk]
    nil
  end

  # The following code attempts to warn about annotation methods already being defined on the class/module.
  # But it doesn't work because `extended` gets called *after* the module's methods are already added...
  # def self.extended(other)
  #   [:pre,
  #    :post,
  #    :type,
  #    :var_type,
  #    :attr_accessor_type,
  #    :attr_reader_type,
  #    :attr_type,
  #    :attr_writer_type,
  #    :qdl_alias,
  #    :type_params].each { |a|
  #      warn "QDL WARNING: #{other.to_s} extended QDL::Annotate but already has #{a} defined" if other.respond_to? a
  #    }
  # end
end

# all methods in QDL::Annotate but with an `qdl_` prefix
module QDL::QDLAnnotate
  define_method :qdl_pre, QDL::Annotate.instance_method(:pre)
  define_method :qdl_post, QDL::Annotate.instance_method(:post)
  define_method :qdl_type, QDL::Annotate.instance_method(:type)
  define_method :qdl_var_type, QDL::Annotate.instance_method(:var_type)
  define_method :qdl_alias, QDL::Annotate.instance_method(:qdl_alias)
  define_method :qdl_type_params, QDL::Annotate.instance_method(:type_params)

  # Need to duplicate these methods because they need to call qdl_var_type and qdl_type
  # and couldn't figure out how to do instance_method with a partial argument binding
  def qdl_attr_accessor_type(*args)
    args.each_slice(2) { |name, typ|
      attr_accessor name
      qdl_var_type ("@" + name.to_s), typ
      qdl_type name, "() -> #{typ}"
      qdl_type name.to_s + "=", "(#{typ}) -> #{typ}"
    }
    nil
  end

  def qdl_attr_reader_type(*args)
    args.each_slice(2) { |name, typ|
      attr_reader name
      qdl_var_type ("@" + name.to_s), typ
      qdl_type name, "() -> #{typ}"
    }
    nil
  end

  alias_method :qdl_attr_type, :qdl_attr_reader_type

  def qdl_attr_writer_type(*args)
    args.each_slice(2) { |name, typ|
      attr_writer name
      qdl_var_type ("@" + name.to_s), typ
      qdl_type name.to_s + "=", "(#{typ}) -> #{typ}"
    }
    nil
  end
end

module QDL
  extend QDL::Annotate

  # Add a new type alias.
  # [+name+] must be a string beginning with %.
  # [+typ+] can be either a string, in which case it will be parsed
  # into a type, or a Type.
  def self.type_alias(name, typ)
    raise RuntimeError, "Attempt to redefine type #{name}" if QDL::Globals.special_types[name]
    case typ
    when String
      t = QDL::Globals.parser.scan_str "#T #{typ}"
      QDL::Globals.special_types[name] = t
    when QDL::Type::Type
      QDL::Globals.special_types[name] = typ
    else
      raise RuntimeError, "Unexpected typ argument #{typ.inspect}"
    end
    nil
  end

  def self.nowrap(klass=self)
    QDL.config { |config| config.add_nowrap(klass) }
    nil
  end

  # Register [+ blk +] to be executed when `qdl_do_typecheck [+ sym +]` is called.
  # The blk will be called with sym as its argument. The order
  # in which multiple blks for the same sym will be executed is unspecified
  def self.at(sym, &blk)
    QDL::Globals.to_do_at[sym] = [] unless QDL::Globals.to_do_at[sym]
    QDL::Globals.to_do_at[sym] << blk
  end

  # Mark all untyped methods added in the passed block as being inferred
  def self.infer_added(tag, include: nil, exclude: nil)
    dirs = QDL::Globals.infer_added_filter_dirs
    tmp = QDL::Globals.infer_added

    filter_list = nil
    filter_list = FileList[include] if include
    filter_list = (filter_list || FileList['**/*']).exclude(exclude) if exclude

    QDL::Globals.infer_added = tag
    QDL::Globals.infer_added_filter_dirs = filter_list && filter_list.map { |f| File.join(Dir.pwd, f) }

    if QDL::Globals.infer_added_filter_dirs
      QDL::Logging.log :wrap, :debug, "Got Filter..."
      QDL::Globals.infer_added_filter_dirs.each { |d| QDL::Logging.log :wrap, :trace, "\t#{d}" }
    else
      QDL::Logging.log :wrap, :debug, "No filter..."
    end

    yield

    QDL::Globals.infer_added = tmp
    QDL::Globals.infer_added_filter_dirs = dirs
  end

  # Invokes all callbacks from qdl_at(sym), in unspecified order.
  # Afterwards, type checks all methods that had annotation `typecheck: sym' at type call, in unspecified order.
  def self.do_typecheck(sym)
    if QDL::Globals.to_do_at[sym]
      QDL::Globals.to_do_at[sym].each { |blk| blk.call(sym) }
    end
    QDL::Globals.to_do_at[sym] = Array.new
    return unless QDL::Globals.to_typecheck[sym]
    QDL::Globals.to_typecheck[sym].each { |klass, meth|
      QDL::Typecheck.typecheck(klass, meth)
    }
    QDL::Globals.to_typecheck[sym] = Set.new
    nil
  end

  def self.do_infer(sym, render_report: true)
    return unless QDL::Globals.to_infer[sym]

    QDL::Config.instance.use_unknown_types = true
    $stn = 0
    num_casts = 0
    time = Time.now

    QDL::Globals.to_infer[sym].each { |klass, meth|
      begin
        QDL::Typecheck.infer klass, meth
        num_casts += QDL::Typecheck.get_num_casts if QDL::Typecheck.get_num_casts
      rescue Exception => e
        if QDL::Config.instance.continue_on_errors
          QDL::Logging.log :inference, :debug_error, "Error: #{e}; recording %dyn"
          # QDL::Globals.info.set(klass, meth, :type, [QDL::Globals.types[:dyn]])
        else
          raise e
        end
      end
    }

    QDL::Globals.to_infer[sym] = Set.new
    QDL::Typecheck.resolve_constraints

    report = QDL::Typecheck.extract_solutions

    report.to_csv 'infer_data_new.csv' if render_report
    report.to_sorbet 'infer_data.rbi' if render_report

    time = Time.now - time

    QDL::Logging.log :inference, :info, "Total time taken: #{time}."
    QDL::Logging.log :inference, :info, "Total number of type casts used: #{num_casts}."
    QDL::Logging.log :inference, :info, "Total amount of time spent on stn: #{$stn}."
  end

  def self.load_sequel_schema(db)
    db.disconnect
    db.tables.each { |table|
      hash_str = "{ "
      kl_name = table.to_s.camelize.singularize
      db.schema(table).each { |col|
        hash_str << "#{col[0]}: "
        typ = col[1][:type].to_s.camelize
        if typ == "Datetime"
          typ = "DateTime or Time" ## Sequel accepts both
        elsif typ == "Boolean"
          typ = "%bool"
        elsif typ == "Text"
          typ = "String"
        end
        hash_str << "#{typ},"
        QDL.type kl_name, col[0], "() -> #{typ}", wrap: false
        QDL.type kl_name, "#{col[0]}=", "(#{typ}) -> #{typ}", wrap: false
      }
      hash_str.chomp!(",") << " }"
      QDL::Globals.seq_db_schema[table] = QDL::Globals.parser.scan_str "#T #{hash_str}"
    }
  end

  def self.load_rails_schema
    return if !defined?(Rails) || (File.basename($0) == "rake") || $dont_load_rails
    ::Rails.application.eager_load! # load Rails app
    models = ActiveRecord::Base.descendants.each { |m|
      begin
        ## load schema for each Rails model
        m.send(:load_schema) unless m.abstract_class?
      rescue
      end }

    models.each { |model|
      next if !model.table_exists?
      next if model.to_s == "ApplicationRecord"
      next if model.to_s == "GroupManager"
      QDL.nowrap model
      s1 = {}
      model.columns_hash.each { |k, v| t_name = v.type.to_s.camelize
        ## Map SQL column types to the corresponding QDL type
        if t_name == "Boolean"
          t_name = "%bool"
          s1[k] = QDL::Globals.types[:bool]
        elsif t_name == "Datetime"
          t_name = "DateTime or Time"
          s1[k] = QDL::Type::UnionType.new(QDL::Type::NominalType.new(Time), QDL::Type::NominalType.new(DateTime))
        elsif t_name == "Text"
          ## difference between `text` and `string` is in the SQL types they're mapped to, not in Ruby types
          t_name = "String"
          s1[k] = QDL::Globals.types[:string]
        else
          s1[k] = QDL::Type::NominalType.new(t_name)
        end
        QDL.type model, (k+"=").to_sym, "(#{t_name}) -> #{t_name}", wrap: false ## create method type for column setter
        QDL.type model, (k).to_sym, "() -> #{t_name}", wrap: false ## create method type for column getter
        QDL.type model, (k+"?").to_sym, "() -> %bool", wrap: false if t_name == "%bool" ## boolean column attributes get automatic `?` method
      }
      s2 = s1.transform_keys { |k| k.to_sym }
      assoc = {}
      model.reflect_on_all_associations.each { |a|
        class_name = a.class_name.starts_with?("::") ? a.class_name[2..-1] : a.class_name
        ## Generate method types based on associations
        add_ar_assoc(assoc, a.macro, a.name)
        if a.name.to_s.pluralize == a.name.to_s ## plural association
          ## This actually returns an Associations CollectionProxy, which is a descendant of ActiveRecord_Relation (see below actual type). This makes no difference in practice.
          QDL.type model, a.name, "() -> ActiveRecord_Relation<#{class_name}>", wrap: false
          QDL.type model, "#{a.name}=", "(ActiveRecord_Relation<#{class_name}> or Array<#{class_name}>) -> ``targs[0]``", wrap: false
          #ActiveRecord_Associations_CollectionProxy<#{a.name.to_s.camelize.singularize}>'
        else
          ## association is singular, we just return an instance of associated class
          QDL.type model, a.name, "() -> #{class_name}", wrap: false
          QDL.type model, "#{a.name}=", "(#{class_name}) -> #{class_name}", wrap: false
        end
      }
      s2[:__associations] = QDL::Type::FiniteHashType.new(assoc, nil)
      base_name = model.to_s
      base_type = QDL::Type::NominalType.new(model.to_s)
      hash_type = QDL::Type::FiniteHashType.new(s2, nil)
      schema = QDL::Type::GenericType.new(base_type, hash_type)
      QDL::Globals.ar_db_schema[base_name.to_sym] = schema
    }
  end

  def self.check_type_code
    QDL.config { |config| config.use_comp_types = false }
    count = 1
    QDL::Globals.dep_types.each { |klass, meth, typ|
      klass = QDL::Util.has_singleton_marker(klass) ? QDL::Util.remove_singleton_marker(klass) : klass
      arg_list = "(trec, targs"
      type_list = "(QDL::Type::Type, Array<QDL::Type::Type>"
      (typ.args+[typ.ret]+[typ.block]).each { |t|
        ## First collect all bindings to be used during type checking.
        if (t.is_a?(QDL::Type::BoundArgType))
          arg_list << ", #{t.name}"
          type_list << ", #{t.type.class}"
        end
      }
      arg_list << ")"
      type_list << ")"
      code_type = QDL::Globals.parser.scan_str "#{type_list} -> QDL::Type::Type"
      (typ.args+[typ.ret]+[typ.block]).each { |t|
        if t.is_a?(QDL::Type::ComputedType)
          meth = cleanse_meth_name(meth)
          if klass.to_s.include?("::") ## hacky way around namespace issue
            tmp_meth =  "def klass.tc_#{meth}#{count}#{arg_list} #{t.code}; end"
            tmp_eval = "klass = #{klass} ; #{tmp_meth}"
          else
            tmp_meth = tmp_eval = "def #{klass}.tc_#{meth}#{count}#{arg_list} #{t.code}; end"
          end
          eval tmp_eval
          ast = Parser::CurrentRuby.parse tmp_meth
          QDL::Typecheck.typecheck("[s]#{klass}", "tc_#{meth}#{count}".to_sym, ast, [code_type])
          count += 1
        end
      }
    }
    QDL.do_typecheck :type_code
    QDL.config { |config| config.use_comp_types = true }
    true
  end

  def self.cleanse_meth_name(meth)
    meth = meth.to_s
    meth.gsub!("%", "percent")
    meth.gsub!("&", "ampersand")
    meth.gsub!("*", "asterisk")
    meth.gsub!("+", "plus")
    meth.gsub!("-", "dash")
    meth.gsub!("@", "at")
    meth.gsub!("/", "slash")
    meth.gsub!("<", "lt")
    meth.gsub!(">", "gt")
    meth.gsub!("=", "eq")
    meth.gsub!("[", "lbracket")
    meth.gsub!("]", "rbracket")
    meth.gsub!("^", "carrot")
    meth.gsub!("|", "line")
    meth.gsub!("~", "line")
    meth.gsub!("?", "qmark")
    meth.gsub!("!", "bang")
    meth
  end

  # Does nothing at run time
  def self.note_type(x)
    return x
  end

  def self.remove_type(klass, meth)
    raise RuntimeError, "No existing type for #{QDL::Util.pp_klass_method(klass, meth)}" unless QDL::Globals.info.has? klass, meth, :type
    QDL::Globals.info.remove klass, meth, :type
    nil
  end

  # Returns a new object that wraps self in a type cast. If force is true this cast is *unchecked*, so use with caution
  def self.type_cast(obj, typ, force: false)
    new_typ = if typ.is_a? QDL::Type::Type
                typ
              elsif QDL::Util.has_singleton_marker(typ)
                QDL::Type::SingletonType.new(QDL::Globals.parser.scan_str("#T #{QDL::Util.remove_singleton_marker(typ)}").klass)
              else
                QDL::Globals.parser.scan_str "#T #{typ}"
              end
    raise RuntimeError, "type cast error: self  of class #{self.class} not a member of #{new_typ}" unless force || new_typ.member?(obj)
    new_obj = SimpleDelegator.new(obj)
    new_obj.instance_variable_set('@__qdl_type', new_typ)
    new_obj
  end

  # [+typs+] is an array of types, classes, symbols, or strings to instantiate
  # the type parameters. If a class, symbol, or string is given, it is
  # converted to a NominalType.
  def self.instantiate!(obj, *typs, check: false)
    klass = obj.class.to_s
    klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
    formals, _, all = QDL::Globals.type_params[klass]
    raise RuntimeError, "Receiver is of class #{klass}, which is not parameterized" unless formals
    raise RuntimeError, "Expecting #{formals.size} type parameters, got #{typs.size}" unless formals.size == typs.size
    raise RuntimeError, "Instance already has type instantiation" if obj.instance_variable_defined?(:@__qdl_type) && obj.instance_variable_get(:@__qdl_type)
    new_typs = typs.map { |t| if t.is_a? QDL::Type::Type then t else QDL::Globals.parser.scan_str "#T #{t}" end }
    t = QDL::Type::GenericType.new(QDL::Type::NominalType.new(klass), *new_typs)
    if check
      if all.instance_of? Symbol
        obj.send(all) { |*objs|
          new_typs.zip(objs).each { |nt, o|
            if nt.instance_of? QDL::Type::GenericType # require o to be instantiated
              t_o = QDL::Util.qdl_type(o)
              raise QDL::Type::TypeError, "Expecting element of type #{nt.to_s}, but got uninstantiated object #{o.inspect}" unless t_o
              raise QDL::Type::TypeError, "Expecting type #{nt.to_s}, got type #{t_o.to_s}" unless t_o <= nt
            else
              raise QDL::Type::TypeError, "Expecting type #{nt.to_s}, got #{o.inspect}" unless nt.member? o
            end
          }
        }
      else
        raise QDL::Type::TypeError, "Not an instance of #{t}" unless instance_exec(*new_typs, &all)
      end
    end
    obj.instance_variable_set(:@__qdl_type, t)
    obj
  end

  def self.deinstantiate!(obj)
    klass = obj.class.to_s
    klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
    raise RuntimeError, "Class #{self.to_s} is not parameterized" unless QDL::Globals.type_params[klass]
    raise RuntimeError, "Instance is not instantiated" unless obj.instance_variable_get(:@__qdl_type).instance_of?(QDL::Type::GenericType)
    obj.instance_variable_set(:@__qdl_type, nil)
    obj
  end

  # Aliases contracts for meth_old and meth_new in klass. Currently, this
  # must be called for any aliases or they will not be wrapped with
  # contracts.
  def self.alias(klass, new_name, old_name)
    klass = klass.to_s
    klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
    QDL::Globals.aliases[klass] = {} unless QDL::Globals.aliases[klass]
    if QDL::Globals.aliases[klass][new_name]
      raise RuntimeError,
            "Tried to alias #{new_name}, already aliased to #{QDL::Globals.aliases[klass][new_name]}"
    end
    QDL::Globals.aliases[klass][new_name] = old_name

    if Module.const_defined?(klass) && QDL::Util.to_class(klass).method_defined?(new_name)
      QDL::Wrap.wrap(klass, new_name)
    else
      QDL::Globals.to_wrap << [klass, old_name]
    end
    nil
  end


  private
  def self.add_ar_assoc(hash, aname, aklass)
    kl_type = QDL::Type::SingletonType.new(aklass)
    if hash[aname]
      hash[aname] = QDL::Type::UnionType.new(hash[aname], kl_type)
    else
      hash[aname] = kl_type unless hash[aname]
    end
    hash
  end
end

class Object
  def singleton_method_added(meth)
    klass = self.to_s
    klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
    sklass = QDL::Util.add_singleton_marker(klass)
    QDL::Wrap.do_method_added(self, true, sklass, meth)
    nil
  end
end

class Module
  define_method :singleton_method_added, Object.instance_method(:singleton_method_added)

  QDL::Util.silent_warnings {

  def method_added(meth)
    klass = self.to_s
    klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
    QDL::Wrap.do_method_added(self, false, klass, meth)
    nil
  end

  def included(other)
    QDL::Globals.module_mixees[self] = [] unless QDL::Globals.module_mixees[self]
    QDL::Globals.module_mixees[self] << [other, :include]
  end

  def extended(other)
    QDL::Globals.module_mixees[self] = [] unless QDL::Globals.module_mixees[self]
    QDL::Globals.module_mixees[self] << [other, :extend]
  end

  }
end

class Class
  def ===(x)
    if x.method(:is_a?).owner == SimpleDelegator then super(x.__getobj__) else super(x) end
  end
end

class SimpleDelegator
  ## pass methods through to wrapped object
  ## necessary when type casts are inside type-level code
  def is_a?(c)
    __getobj__.is_a?(c)
  end

  def instance_of?(c)
    __getobj__.instance_of?(c)
  end

  def kind_of?(c)
    __getobj__.kind_of?(c)
  end

  def ===(x)
    __getobj__ === x
  end

  def ==(x)
    __getobj__ == x
  end

  def class
     __getobj__.class
  end

  def nil?
     __getobj__.nil?
  end

end
