QDL.nowrap :Hash

QDL.type_params :Hash, [:k, :v], :all?

def Hash.output_type(trec, targs, meth_name, default1, default2=default1, nil_default: false, use_sing_val: true)
  case trec
  when QDL::Type::FiniteHashType
    if targs.empty? || targs.all? { |t| t.is_a?(QDL::Type::SingletonType) }
      vals = QDL.type_cast((if use_sing_val then targs.map { |t| QDL.type_cast(t, "QDL::Type::SingletonType").val } else targs end), "Array<%any>", force: true)
      res = QDL.type_cast(trec.elts.send(meth_name, *vals), "Object", force: true)
      if nil_default && res.nil?
        if default1 == :promoted_val
          # ret = trec.promote.params[1]
          return trec.promote.params[1]
        elsif default1 == :promoted_key
          return trec.promote.params[0]
        elsif default1 == :default_or_promoted_val
          if trec.default then
            return assign_output(trec, targs + [trec.default])
          else
            return trec.promote.params[1]
          end
        else
          return QDL::Globals.parser.scan_str "#T #{default1}"
        end
      end
      to_type(res)
    else
      if default1 == :promoted_val
        return trec.promote.params[1]
      elsif default1 == :promoted_key
        return trec.promote.params[0]
      elsif default1 == :default_or_promoted_val
        if trec.default then
          return assign_output(trec, targs + [trec.default])
        else
          return trec.promote.params[1]
        end
      else
        QDL::Globals.parser.scan_str "#T #{default1}"
      end
    end
  else
    if default2 == "k"
      trec.params[0] ## equivalent of k in Hash<k, v>
    elsif default2 == "v"
      if trec.to_s == 'ActionController::Parameters'
        return QDL::Globals.parser.scan_str "#T (Symbol or String)"
      else
        trec.params[1] ## equivalent of v in Hash<k, v>
      end
    else
      QDL::Globals.parser.scan_str "#T #{default2}"
    end
  end
end
QDL.type Hash, 'self.output_type', "(QDL::Type::Type, Array<QDL::Type::Type>, Symbol, Symbol or String, ?(Symbol or String), { nil_default: ?%bool, use_sing_val: ?%bool } ) -> QDL::Type::Type", typecheck: :type_code, wrap: false


def Hash.to_type(t)
  if t.is_a?(QDL::Type::Type)
    t
  elsif t.is_a? Array
    QDL::Type::TupleType.new(*(t.map { |i| to_type(i) }))
  elsif t.is_a? Numeric
    if QDL::Config.instance.number_mode
      QDL::Type::NominalType.new(Integer)
    else
      QDL::Type::SingletonType.new(t)
    end
  elsif t.is_a?(Symbol) || t.is_a?(TrueClass) || t.is_a?(FalseClass) || t.is_a?(Module)
    QDL::Type::SingletonType.new(t)
  else
    QDL::Type::NominalType.new(t.class)
  end
end
QDL.type Hash, 'self.to_type', "(%any) -> QDL::Type::Type", typecheck: :type_code, wrap: false

def Hash.any_or_k(trec)
  case trec
  when QDL::Type::FiniteHashType
    QDL::Globals.types[:top]
  when QDL::Type::GenericType
    #QDL::Globals.parser.scan_str "#T k"
    trec.params[0] ## equivalent of k in Hash<k, v>
  when QDL::Type::NominalType
    if trec.to_s == 'ActionController::Parameters'
      return QDL::Globals.parser.scan_str "#T (Symbol or String)"
    else
      return QDL::Globals.parser.scan_str "#T k"
    end
  else
    raise "unexpected, got #{trec}"
  end
end
QDL.type Hash, 'self.any_or_k', "(QDL::Type::Type) -> QDL::Type::Type", typecheck: :type_code, wrap: false

def Hash.any_or_v(trec)
  case trec
  when QDL::Type::FiniteHashType
    QDL::Globals.types[:top]
  when QDL::Type::GenericType
  #QDL::Globals.parser.scan_str "#T v"
    trec.params[1] ## equivalent of v in Hash<k, v>
  else
    raise "unexpected"
  end
end
QDL.type Hash, 'self.any_or_v', "(QDL::Type::Type) -> QDL::Type::Type", typecheck: :type_code, wrap: false

def Hash.promoted_or_v(trec)
  case trec
  when QDL::Type::FiniteHashType
    trec.promote.params[1]
  when QDL::Type::GenericType
    #QDL::Globals.parser.scan_str "#T v"
    trec.params[1]
  else
    raise "unexpected"
  end
end
QDL.type Hash, 'self.promoted_or_v', "(QDL::Type::Type) -> QDL::Type::Type", typecheck: :type_code, wrap: false

def Hash.promoted_or_k(trec)
  case trec
  when QDL::Type::FiniteHashType
    trec.promote.params[0]
  when QDL::Type::GenericType
    #QDL::Globals.parser.scan_str "#T v"
    trec.params[0]
  else
    raise "unexpected"
  end
end


def Hash.weak_promote(val)
  case val
  when QDL::Type::UnionType
    if val.types.all? { |t| t.is_a?(QDL::Type::SingletonType) }
      klass = QDL.type_cast(val.types[0], "QDL::Type::SingletonType", force: true).nominal.klass
      if val.types.all? { |t| QDL.type_cast(t, "QDL::Type::SingletonType", force: true).nominal.klass == klass }
        return QDL::Type::NominalType.new(klass)
      else
        return val
      end
    else
      return val
    end
  else
    val
  end
end
QDL.type Hash, 'self.weak_promote', "(QDL::Type::Type) -> QDL::Type::Type", typecheck: :type_code, wrap: false

#QDL.type :Hash, 'self.[]', '(*%any) -> ``hash_create_output_from_list(targs)``'
QDL.type :Hash, 'self.[]', '(*%any) -> ``hash_create_output(targs)``'

def Hash.hash_create_output_from_list(targs)
  raise QDL::Typecheck::StaticTypeError, "Hash[...] expect only 1 argument. Have #{targs}." if targs.size > 1
  raise QDL::Typecheck::StaticTypeError, "The argument has to be an array or tuple, got #{targs[0]}" unless ((targs[0].is_a?(QDL::Type::GenericType) && targs[0].base.klass == Array) || targs[0].is_a?(QDL::Type::VarType))

  case targs[0]
  when QDL::Type::VarType
    return QDL::Globals.types[:hash]
  else
    case targs[0].params[0]
    when QDL::Type::GenericType
      return QDL::Globals.parser.scan_str "#T Hash<#{targs[0].params[0].params[0]}, #{targs[0].params[0].params[0]}>"
    when QDL::Type::TupleType
      return QDL::Type::GenericType.new(QDL::Type::NominalType.new(Hash), targs[0].params[0].params[0], targs[0].params[0].params[1])
    end
  end
end

def Hash.hash_create_output(targs)
  return hash_create_output_from_list(targs) if targs.size == 1

  raise QDL::Typecheck::StaticTypeError, "Hash.[] expects an even number of arguments. Have #{targs}." if targs.size.odd?
  args = QDL.type_cast([], "Array<%any>", force: true)
  i = -1
  args = targs.map { |a| i = i+1 ; if i.even? && a.is_a?(QDL::Type::SingletonType) then QDL.type_cast(a, "QDL::Type::SingletonType", force: true).val else a end }
  QDL::Type::FiniteHashType.new(QDL.type_cast(Hash[*args], "Hash<%any, QDL::Type::Type>", force: true), nil)
end
QDL.type Hash, 'self.hash_create_output', "(Array<QDL::Type::Type>) -> QDL::Type::Type", typecheck: :type_code, wrap: false

QDL.type :Hash, :[], '(``any_or_k(trec)``) -> ``output_type(trec, targs, :[], :default_or_promoted_val, "v", nil_default: true)``'

QDL.type :Hash, :[]=, '(``any_or_k(trec)``, ``any_or_v(trec)``) -> ``assign_output(trec, targs)``'


def Hash.assign_output(trec, targs)
  case trec
  when QDL::Type::FiniteHashType
    case targs[0]
    when QDL::Type::SingletonType ### TODO: adjust for strings
      argval = QDL.type_cast(targs[0], "QDL::Type::SingletonType", force: true).val
      trec.elts[argval] = QDL::Type::UnionType.new(trec.elts[argval], targs[1]).canonical
      trec.elts[argval] = weak_promote(trec.elts[argval]) if QDL::Config.instance.weak_update_promote
      raise QDL::Typecheck::StaticTypeError, "Failed to mutate hash: new hash does not match prior type constraints." unless trec.check_bounds(true)
      return targs[1]
    else
      raise "Unable to promote tuple #{trec} to Hash." unless trec.promote!(targs[0], targs[1])
      return targs[1]
    end
  else
    #QDL::Globals.parser.scan_str "#T v"
    trec.params[1]
  end
end
QDL.type Hash, 'self.assign_output', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", typecheck: :type_code, wrap: false

QDL.type Hash, :initialize, "(*%any) -> ``QDL::Type::FiniteHashType.new({}, nil, default: targs[0])``"
QDL.type Hash, :initialize, "() { (Hash<a, b>, x) -> y } -> ``QDL::Type::GenericType.new(QDL::Globals.types[:hash], QDL::Globals.types[:top], QDL::Globals.types[:top])``"

QDL.type :Hash, :store, '(``any_or_k(trec)``, ``any_or_v(trec)``) -> ``assign_output(trec, targs)``'
QDL.type :Hash, :assoc, '(``any_or_k(trec)``) -> ``QDL::Type::TupleType.new(targs[0], output_type(trec, targs, :[], :promoted_val, "v", nil_default: true))``'
QDL.type :Hash, :clear, '() -> self'
QDL.type :Hash, :compare_by_identity, '() -> self'
QDL.type :Hash, :compare_by_identity?,  '() -> %bool'
QDL.type :Hash, :default, '() -> ``promoted_or_v(trec)``'
QDL.type :Hash, :default, '(``any_or_k(trec)``) -> ``promoted_or_v(trec)``'
QDL.type :Hash, :default=, '(``promoted_or_v(trec)``) -> ``promoted_or_v(trec)``'

QDL.type :Hash, :delete, '(``any_or_k(trec)``) -> ``delete_output(trec, targs, false)``'
QDL.type :Hash, :delete, '(``any_or_k(trec)``) { (``any_or_k(trec)``) -> u } -> ``delete_output(trec, targs, true)``'

def Hash.delete_output(trec, targs, block)
  case trec
  when QDL::Type::FiniteHashType
    case targs[0]
    when QDL::Type::SingletonType
      argval = QDL.type_cast(targs[0], "QDL::Type::SingletonType", force: true).val
      if trec.elts.include?(argval)
        trec.elts[argval]
      else
        trec.promote.params[1]
      end
    else
      if block
        QDL::Type::UnionType.new(trec.promote.params[1], QDL::Globals.parser.scan_str("#T u"))
      else
        trec.promote.params[1]
      end
    end
  else
    return QDL::Globals.types[:nil] if trec.to_s == "ActionController::Parameters"
    t = (if block then "u or v" else "v" end)
    QDL::Globals.parser.scan_str "#T #{t}"
  end
end
QDL.type Hash, 'self.delete_output', "(QDL::Type::Type, Array<QDL::Type::Type>, %bool) -> QDL::Type::Type", typecheck: :type_code, wrap: false

QDL.type :Hash, :delete_if, '() { (``promoted_or_k(trec)``, ``promoted_or_v(trec)``) -> %any } -> self'
QDL.type :Hash, :delete_if, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), QDL::Type::TupleType.new(any_or_k(trec), any_or_v(trec)))``' ## I had made a mistake here, type checker caught it.
QDL.type :Hash, :each, '() { (``promoted_or_k(trec)``, ``promoted_or_v(trec)``) -> %any } -> self'
QDL.type :Hash, :each, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), QDL::Type::TupleType.new(any_or_k(trec), any_or_v(trec)))``' ## I had made a mistake here, type checker caught it.
QDL.type :Hash, :each_pair, '() { (``promoted_or_k(trec)``, ``promoted_or_v(trec)``) -> %any } -> self'
QDL.type :Hash, :each_pair, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), QDL::Type::TupleType.new(any_or_k(trec), any_or_v(trec)))``' ## I had made a mistake here, type checker caught it.
QDL.type :Hash, :each_key, '() { (``promoted_or_k(trec)``) -> %any } -> self'
QDL.type :Hash, :each_key, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), any_or_k(trec))``'
QDL.type :Hash, :each_value, '() { (``promoted_or_v(trec)``) -> %any } -> self'
QDL.type :Hash, :each_value, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), any_or_v(trec))``'
QDL.type :Hash, :empty?, '() -> ``output_type(trec, targs, :empty?, "%bool")``'
QDL.type :Hash, :fetch, '(``any_or_k(trec)``) -> ``output_type(trec, targs, :fetch, :promoted_val, "v", nil_default: true)``'
#QDL.type :Hash, :fetch, '(``any_or_k(trec)``, u) -> ``QDL::Type::UnionType.new(QDL::Globals.parser.scan_str("#T u"), output_type(trec, targs, :fetch, :promoted_val, "v", nil_default: true))``'
QDL.type :Hash, :fetch, '(``any_or_k(trec)``, ``targs[1] ? targs[1] : QDL::Globals.types[:top]``) -> ``QDL::Type::UnionType.new(targs[1] ? targs[1] : QDL::Globals.types[:top], output_type(trec, targs, :fetch, :promoted_val, "v", nil_default: true))``'
QDL.type :Hash, :fetch, '(``any_or_k(trec)``) { (``any_or_k(trec)``) -> u } -> ``QDL::Type::UnionType.new(QDL::Globals.parser.scan_str("#T u"), output_type(trec, targs, :fetch, :promoted_val, "v", nil_default: true))``'
QDL.type :Hash, :fetch, '(``any_or_k(trec)``) { () -> u } -> ``QDL::Type::UnionType.new(QDL::Globals.parser.scan_str("#T u"), output_type(trec, targs, :fetch, :promoted_val, "v", nil_default: true))``'
QDL.type :Hash, :first, '() -> ``output_type(trec, targs, :first, "[k, v]", nil_default: true)``'
QDL.type :Hash, :member?, '(%any) -> ``output_type(trec, targs, :member?, "%bool")``'
QDL.type :Hash, :has_key?, '(%any) -> ``output_type(trec, targs, :has_key?, "%bool")``'
QDL.type :Hash, :key?, '(%any) -> ``output_type(trec, targs, :key?, "%bool")``'
QDL.type :Hash, :has_value?, '(%any) -> ``output_type(trec, targs, :has_value?, "%bool")``'
QDL.type :Hash, :value?, '(%any) -> ``output_type(trec, targs, :value?, "%bool")``'
QDL.type :Hash, :to_s, '() -> String'
QDL.type :Hash, :inspect, '() -> String'
QDL.type :Hash, :invert, '() -> ``invert_output(trec)``'


def Hash.invert_output(trec)
  case trec
  when QDL::Type::FiniteHashType
    hash = trec.elts.invert
    hash = Hash[hash.map { |k, v| if !QDL.type_cast(v, "Object", force: true).is_a?(QDL::Type::Type) then [k, QDL::Type::SingletonType.new(v)] else [k, v] end }]
    QDL::Type::FiniteHashType.new(QDL.type_cast(hash, "Hash<%any, QDL::Type::Type>", force: true), nil)
  else
    QDL::Type::GenericType.new(QDL::Globals.types[:hash], trec.params[1], trec.params[0])
    #QDL::Globals.parser.scan_str "#T Hash<v, k>"
  end
end
QDL.type Hash, 'self.invert_output', "(QDL::Type::Type) -> QDL::Type::Type", typecheck: :type_code, wrap: false

QDL.type :Hash, :keep_if, '() { (``any_or_k(trec)``,``any_or_v(trec)``) -> %bool } -> self'
QDL.type :Hash, :keep_if, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), QDL::Type::TupleType.new(any_or_k(trec), any_or_v(trec)))``' ## I had made a mistake here, type checker caught it.
QDL.type :Hash, :key, '(%any) -> ``output_type(trec, targs, :key, :promoted_key, "k", nil_default: true, use_sing_val: false)``'
QDL.type :Hash, :keys, '() -> ``output_type(trec, targs, :keys, "Array<k>")``'
QDL.type :Hash, :length, '() -> ``output_type(trec, targs, :length, "Integer")``'
QDL.type :Hash, :size, '() -> ``output_type(trec, targs, :size, "Integer")``'
QDL.type :Hash, :merge, '(``merge_input(trec, targs)``) -> ``merge_output(trec, targs)``'
QDL.type :Hash, :merge!, '(``merge_input(trec, targs, true)``) -> ``merge_output(trec, targs, true)``'


def Hash.merge_input(trec, targs, mutate=false)
  case targs[0]
  when QDL::Type::FiniteHashType
    return targs[0]
  when QDL::Type::GenericType, QDL::Type::VarType
    if mutate
      raise "Unable to promote #{trec}." if trec.is_a?(QDL::Type::FiniteHashType) && !trec.promote!
      return trec.canonical
      #return QDL::Globals.parser.scan_str "#T Hash<k, v>"
    else
      if trec.is_a?(QDL::Type::GenericType)
        return QDL::Globals.parser.scan_str "#T Hash<a, b>"
      else
        return targs[0]
      end
    end
  else
    QDL::Globals.types[:hash]
  end
end
QDL.type Hash, 'self.merge_input', "(QDL::Type::Type, Array<QDL::Type::Type>, ?%bool) -> QDL::Type::Type", typecheck: :type_code, wrap: false


def Hash.merge_output(trec, targs, mutate=false)
  case trec
  when QDL::Type::NominalType
    return QDL::Globals.types[:hash]
  when QDL::Type::GenericType
    case targs[0]
    when QDL::Type::FiniteHashType
      promoted = QDL.type_cast(targs[0], "QDL::Type::FiniteHashType", force: true).promote
      key_union = QDL::Type::UnionType.new(promoted.params[0], trec.params[0]).canonical
      value_union = QDL::Type::UnionType.new(promoted.params[1], trec.params[1]).canonical
      if mutate
        raise "Call to `merge!` would change type of Hash." unless (key_union == trec.params[0]) && (value_union == trec.params[1])
        return trec
      else
        return QDL::Type::GenericType.new(trec.base, key_union, value_union)
      end
    when QDL::Type::GenericType
      ret = (if mutate then "Hash<k, v>" else "Hash<a or k, b or v>" end)
      return QDL::Globals.parser.scan_str "#T #{ret}"
    when QDL::Type::VarType
      ## Return Hash<x, y> for fresh vars x and y.
      return QDL::Type::GenericType.new(QDL::Globals.types[:hash], QDL::Type::VarType.new(cls: targs[0].cls, meth: targs[0].meth, category: :hash_param_key, name: "hash_param_key_#{targs[0].name}"),
                                            QDL::Type::VarType.new(cls: targs[0].cls, meth: targs[0].meth, category: :hash_param_val, name: "hash_param_val_#{targs[0].name}"))
    else
      ## targs[0] should just be hash here
      return QDL::Globals.types[:hash]
    end
  when QDL::Type::FiniteHashType
    case targs[0]
    when QDL::Type::FiniteHashType
      arg = QDL.type_cast(targs[0], "QDL::Type::FiniteHashType", force: true)
      if mutate
        if arg.elts.any? { |k, v| !QDL.type_cast(k, "Object", force: true).is_a?(Symbol) }
          arg_key = arg.promote.params[0]
          arg_val = arg.promote.params[1]
          raise "Unable to promote tuple #{trec} to Hash." unless trec.promote!(arg_key, arg_val)
          return trec
        end
        trec.elts = QDL.type_cast(Hash[trec.elts.map { |k, v| if arg.elts.has_key?(k) then [k, QDL::Type::UnionType.new(arg.elts[k], v).canonical] else [k, v] end } ].merge(arg.elts), "Hash<%any, QDL::Type::Type>", force: true)
        raise QDL::Typecheck::StaticTypeError, "Failed to mutate hash: new hash does not match prior type constraints." unless trec.check_bounds(true)
        return trec
      else
        return QDL::Type::FiniteHashType.new(trec.elts.merge(arg.elts), nil)
      end
    when QDL::Type::GenericType
      arg0 = QDL.type_cast(targs[0], "QDL::Type::GenericType", force: true)
      promoted = trec.promote
      key_union = QDL::Type::UnionType.new(promoted.params[0], arg0.params[0]).canonical
      value_union = QDL::Type::UnionType.new(promoted.params[1], arg0.params[1]).canonical
      if mutate
        raise "Unable to promote tuple #{trec} to Hash." unless trec.promote!(arg0.params[0], arg0.params[1])
        return trec
      else
        return QDL::Type::GenericType.new(arg0.base, key_union, value_union)
      end
    when QDL::Type::VarType
      ## Return Hash<x, y> for fresh vars x and y.
      return QDL::Type::GenericType.new(QDL::Globals.types[:hash], QDL::Type::VarType.new(cls: targs[0].cls, meth: targs[0].meth, category: :hash_param_key, name: "hash_param_key_#{targs[0].name}"),
                                        QDL::Type::VarType.new(cls: targs[0].cls, meth: targs[0].meth, category: :hash_param_val, name: "hash_param_val_#{targs[0].name}"))
    else
      ## targs[0] should just be Hash here
      return QDL::Globals.types[:hash]
      #return QDL::Globals.parser.scan_str "#T Hash<k, v>"
    end
  end

end
QDL.type Hash, 'self.merge_output', "(QDL::Type::Type, Array<QDL::Type::Type>, ?%bool) -> QDL::Type::Type", typecheck: :type_code, wrap: false

QDL.type :Hash, :merge, '(Hash<a,b>) { (k,v,b) -> v or b } -> Hash<a or k, b or v>'
QDL.type :Hash, :rassoc, '(``any_or_v(trec)``) -> ``QDL::Type::TupleType.new(output_type(trec, targs, :key, :promoted_key, "k", nil_default: true, use_sing_val: false),targs[0])``'
QDL.type :Hash, :rehash, '() -> self'
QDL.type :Hash, :reject, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), any_or_k(trec), any_or_v(trec))``'
QDL.type :Hash, :reject, '() {(``any_or_k(trec)``,``any_or_v(trec)``) -> %bool} -> self'
QDL.type :Hash, :reject!, '() {(``any_or_k(trec)``,``any_or_v(trec)``) -> %bool} -> self'
QDL.type :Hash, :select, '() {(``any_or_k(trec)``,``any_or_v(trec)``) -> %bool} -> self'
QDL.type :Hash, :select!, '() {(``any_or_k(trec)``,``any_or_v(trec)``) -> %bool} -> self'
QDL.type :Hash, :shift, '() -> ``shift_output(trec)``'


def Hash.shift_output(trec)
  case trec
  when QDL::Type::FiniteHashType
    promoted = trec.promote
    QDL::Type::TupleType.new(*promoted.params) ## Type error found by type checker here.
  else
    #QDL::Globals.parser.scan_str "#T [k, v]"
    QDL::Type::TupleType.new(trec.params[0], trec.params[1])
  end
end
QDL.type Hash, 'self.shift_output', "(QDL::Type::Type) -> QDL::Type::Type", typecheck: :type_code, wrap: false

#QDL.type :Hash, :to_a, '() -> ``output_type(trec, targs, :to_a, "Array<[k, v]>")``'
QDL.type :Hash, :to_a, '() -> ``to_a_output_type(trec)")``'

def Hash.to_a_output_type(trec)
  case trec
  when QDL::Type::FiniteHashType
    to_type(trec.elts.to_a)
  else
    QDL::Type::GenericType.new(QDL::Globals.types[:array], QDL::Type::TupleType.new(trec,params[0], trec.params[1]))
  end
end


#QDL.type :Hash, :values, '() -> ``output_type(trec, targs, :values, "Array<v>")``'
QDL.type :Hash, :values, '() -> ``values_output(trec)``'
def Hash.values_output(trec)
  case trec
  when QDL::Type::FiniteHashType
    to_type(trec.elts.values)
  else
    QDL::Type::GenericType.new(QDL::Globals.types[:array], trec.params[1])
  end
end

QDL.type :Hash, :values_at, '(``values_at_input(trec)``) -> ``values_at_output(trec, targs)``'


def Hash.values_at_input(trec)
  case trec
  when QDL::Type::FiniteHashType
    QDL::Type::VarargType.new(QDL::Globals.types[:top])
  else
    QDL::Type::VarargType.new(trec.params[0])
  end
end
QDL.type Hash, 'self.values_at_input', "(QDL::Type::Type) -> QDL::Type::Type", typecheck: :type_code, wrap: false


def Hash.values_at_output(trec, targs)
  case trec
  when QDL::Type::FiniteHashType
    if targs.all? { |t| t.is_a? QDL::Type::SingletonType }
      res = trec.elts.values_at(*targs.map { |t| QDL.type_cast(t, "QDL::Type::SingletonType<%any>", force: true).val })
      if res.all? { |t| !t.nil? }
        to_type(res)
      else
        QDL::Type::GenericType.new(QDL::Type::NominalType.new(Array), trec.promote.params[1])
      end
    else
      QDL::Type::GenericType.new(QDL::Type::NominalType.new(Array), trec.promote.params[1])
    end
  else
    QDL::Type::GenericType.new(QDL::Type::NominalType.new(Array), trec.params[1])
  end
end
QDL.type Hash, 'self.values_at_output', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", typecheck: :type_code, wrap: false





######### Non-dependent types below #########

QDL.type :Hash, 'self.[]', '(*u) -> Hash<u, u>'  # example: Hash[1,2,3,4]
QDL.type :Hash, 'self.[]', '(Array<[a,b]>) -> Hash<a, b>'
QDL.type :Hash, 'self.[]', '([to_hash: () -> Hash<a, b>]) -> Hash<a, b>'

QDL.type :Hash, :[], '(k) -> v'
QDL.type :Hash, :[]=, '(k, v) -> v'
QDL.type :Hash, :store, '(k,v) -> v'

QDL.type :Hash, :any?, "() { (k, v) -> %any } -> %bool"
# QDL.type :Hash, :assoc, '(k) -> [k, v]' # TODO
QDL.type :Hash, :assoc, '(k) -> Array<k or v>'
QDL.type :Hash, :clear, '() -> Hash<k,v>'
QDL.type :Hash, :compare_by_identity, '() -> Hash<k,v>'
QDL.type :Hash, :compare_by_identity?,  '() -> %bool'
QDL.type :Hash, :default, '(?k) -> v'
QDL.type :Hash, :default, '(k) {(k) -> v} -> v'
QDL.type :Hash, :default=, '(v) -> v'

# TODO: check on default_proc
# QDL.type :Hash, :default_proc, '() -> (Hash<k,v>,k) -> v'
# QDL.type :Hash, :default_proc=, '((Hash<k,v>,k) -> v) -> (Hash<k,v>,k) -> v'

QDL.type :Hash, :delete, '(k) -> v'
QDL.type :Hash, :delete, '(k) { (k) -> u } -> u or v'
QDL.type :Hash, :delete_if, '() { (k,v) -> %bool } -> Hash<k,v>'
QDL.type :Hash, :delete_if, '() -> Enumerator<[k, v]>'
QDL.type :Hash, :each, '() { (k,v) -> %any } -> Hash<k,v>'
QDL.type :Hash, :each, '() -> Enumerator<[k, v]>'
QDL.type :Hash, :each_pair, '() { (k,v) -> %any } -> Hash<k,v>'
QDL.type :Hash, :each_pair, '() -> Enumerator<[k, v]>'
QDL.type :Hash, :each_key, '() { (k) -> %any } -> Hash<k,v>'
QDL.type :Hash, :each_key, '() -> Enumerator<[k, v]>'
QDL.type :Hash, :each_value, '() { (v) -> %any } -> Hash<k,v>'
QDL.type :Hash, :each_value, '() -> Enumerator<[k, v]>'
QDL.type :Hash, :empty?, '() -> %bool'
QDL.type :Hash, :except, '(%any) -> self'
QDL.type :Hash, :fetch, '(k) -> v'
QDL.type :Hash, :fetch, '(k,u) -> u or v'
QDL.type :Hash, :fetch, '(k) { (k) -> u } -> u or v'
QDL.type :Hash, :map, "() { (k, v) -> x } -> Array<x>"
QDL.type :Hash, :member?, '(t) -> %bool'
QDL.type :Hash, :has_key?, '(t) -> %bool'
QDL.type :Hash, :key?, '(t) -> %bool'
QDL.type :Hash, :has_value?, '(t) -> %bool'
QDL.type :Hash, :value?, '(t) -> %bool'
QDL.type :Hash, :to_s, '() -> String'
QDL.type :Hash, :include?, '(%any) -> %bool'
QDL.type :Hash, :inspect, '() -> String'
QDL.type :Hash, :invert, '() -> Hash<v,k>'
QDL.type :Hash, :keep_if, '() { (k,v) -> %bool } -> Hash<k,v>'
QDL.type :Hash, :keep_if, '() -> Enumerator<[k, v]>'
QDL.type :Hash, :key, '(t) -> k'
QDL.type :Hash, :keys, '() -> Array<k>'
QDL.type :Hash, :length, '() -> Integer'
QDL.type :Hash, :size, '() -> Integer'
QDL.type :Hash, :merge, '(Hash<a,b>) -> Hash<a or k, b or v>'
QDL.type :Hash, :merge, '(Hash<a,b>) { (k,v,b) -> v or b } -> Hash<a or k, b or v>'
# QDL.type :Hash, :rassoc, '(k) -> Tuple<k,v>'
QDL.type :Hash, :rassoc, '(k) -> Array<k or v>'
QDL.type :Hash, :rehash, '() -> Hash<k,v>'
QDL.type :Hash, :reject, '() -> Enumerator<[k, v]>'
QDL.type :Hash, :reject, '() {(k,v) -> %bool} -> Hash<k,v>'
QDL.type :Hash, :reject!, '() {(k,v) -> %bool} -> Hash<k,v>'
QDL.type :Hash, :select, '() {(k,v) -> %bool} -> Hash<k,v>'
QDL.type :Hash, :select!, '() {(k,v) -> %bool} -> Hash<k,v>'
# QDL.type :Hash, :shift, '() -> Tuple<k,v>'
QDL.type :Hash, :shift, '() -> Array<k or v>'
# QDL.type :Hash, :to_a, '() -> Array<Tuple<k,v>>'
QDL.type :Hash, :to_a, '() -> Array<Array<k or v>>'
QDL.type :Hash, :to_hash, '() -> self'
QDL.type :Hash, :to_h, '() -> self'
QDL.type :Hash, :values, '() -> Array<v>'
QDL.type :Hash, :values_at, '(*k) -> Array<v>'
QDL.type :Hash, :with_indifferent_access, '() -> self'
