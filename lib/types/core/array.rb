QDL.nowrap :Array

QDL.type_params :Array, [:t], :all?

def Array.to_type(t)
  if t.is_a?(QDL::Type::Type)
    t
  elsif t.is_a?(Array)
    QDL.type_cast(QDL::Type::TupleType.new(*(t.map { |i| to_type(QDL.type_cast(i, "Object")) })), "QDL::Type::TupleType", force: true)
  else
    t = "nil" if t.nil?
    QDL::Globals.parser.scan_str "#T #{t}"
  end
end
QDL.type Array, 'self.to_type', "(Object) -> QDL::Type::Type", wrap: false, typecheck: :type_code


def Array.output_type(trec, targs, meth_name, default1, default2=default1, use_sing_val: true, nil_false_default: false)
  case trec
  when QDL::Type::TupleType
    if targs.empty? || targs.all? { |t| t.is_a?(QDL::Type::SingletonType) }
      vals = QDL.type_cast((if use_sing_val then targs.map { |t| QDL.type_cast(t, "QDL::Type::SingletonType").val } else targs end), "Array<%any>", force: true)
      begin
        res = QDL.type_cast(trec.params.send(meth_name, *vals), "Object", force: true)
      rescue => e#ArgumentError => e
        puts "GOT ERROR #{e} FOR METHOD #{meth_name} CALLED ON TREC #{trec} AND ARGS #{targs}"
        return QDL::Globals.types[:bot]
      end
      if !res && nil_false_default
        if default1 == :promoted_param
          trec.promote.params[0]
        elsif default1 == :promoted_array
          trec.promote
        else
          QDL::Globals.parser.scan_str "#T #{default1}"
        end
      else
        to_type(res)
      end        
    else
      if default1 == :promoted_param
        trec.promote.params[0]
      elsif default1 == :promoted_array
        trec.promote
      else
        QDL::Globals.parser.scan_str "#T #{default1}"
      end
    end
  else
    QDL::Globals.parser.scan_str "#T #{default2}"
  end
end
QDL.type Array, 'self.output_type', "(QDL::Type::Type, Array<QDL::Type::Type>, Symbol, String or Symbol, ?(String or Symbol), { use_sing_val: ?%bool, nil_false_default: ?%bool }) -> QDL::Type::Type", wrap: false, typecheck: :type_code


def Array.any_or_t(trec, vararg=false)
  case trec
  when QDL::Type::TupleType
    ret = QDL::Globals.types[:top]
    if vararg then QDL::Type::VarargType.new(ret) else ret end
  else
    ret = QDL::Globals.parser.scan_str "#T t"
    if vararg then QDL::Type::VarargType.new(ret) else ret end
  end
end
QDL.type Array, 'self.any_or_t', "(QDL::Type::Type, ?%bool) -> QDL::Type::Type", wrap: false, typecheck: :type_code


def Array.promoted_or_t(trec, vararg=false)
  case trec
  when QDL::Type::TupleType
    ret = trec.promote.params[0]
    if vararg then QDL::Type::VarargType.new(ret) else ret end
  else
    ret = QDL::Globals.parser.scan_str "#T t"
    if vararg then QDL::Type::VarargType.new(ret) else ret end
  end
end
QDL.type Array, 'self.promoted_or_t', "(QDL::Type::Type, ?%bool) -> QDL::Type::Type", wrap: false, typecheck: :type_code


def Array.promote_tuple(trec)
  case trec
  when QDL::Type::TupleType
    trec.promote
  else
    trec
  end
end
QDL.type Array, 'self.promote_tuple', "(QDL::Type::Type) -> QDL::Type::Type", wrap: false, typecheck: :type_code


def Array.promote_tuple!(trec)
  case trec
  when QDL::Type::TupleType
    raise "Unable to promote tuple." unless trec.promote!
    trec
  else
    trec
  end
end
QDL.type Array, 'self.promote_tuple!', "(QDL::Type::Type) -> QDL::Type::Type", wrap: false, typecheck: :type_code

QDL.type :Array, :<<, '(``any_or_t(trec)``) -> ``append_push_output(trec, targs, :<<)``'


def Array.append_push_output(trec, targs, meth)
  case trec
  when QDL::Type::TupleType
    QDL.type_cast(trec.params.send(meth, *QDL.type_cast(targs, "Array<%any>")), "%any", force: true)
    raise QDL::Typecheck::StaticTypeError, "Failed to mutate tuple: new tuple does not match prior type constraints." unless trec.check_bounds(true)
    trec
  else
    QDL::Globals.parser.scan_str "#T Array<t>"
  end
end
QDL.type Array, 'self.append_push_output', "(QDL::Type::Type, Array<QDL::Type::Type>, Symbol) -> QDL::Type::Type", typecheck: :type_code, wrap: false

QDL.type :Array, :[], '(Range<Integer>) -> ``output_type(trec, targs, :[], :promoted_array, "Array<t>")``'
QDL.type :Array, :[], '(Integer or Float) -> ``output_type(trec, targs, :[], :promoted_param, "t")``'
QDL.type :Array, :[], '(Integer, Integer) -> ``output_type(trec, targs, :[], :promoted_array, "Array<t>")``'
QDL.type :Array, :&, '(Array<u>) -> ``output_type(trec, targs, :&, :promoted_array, "Array<t>")``'
QDL.type :Array, :*, '(Integer) -> ``output_type(trec, targs, :*, :promoted_array, "Array<t>")``'
QDL.type :Array, :*, '(String) -> ``output_type(trec, targs, :*, "String")``'
QDL.type :Array, :+, '(``plus_input(targs)``) -> ``plus_output(trec, targs)``'


def Array.plus_input(targs)
  case targs[0]
  when QDL::Type::TupleType
    return targs[0]
  when QDL::Type::GenericType, QDL::Type::VarType
    parse_string = defined?(Rails) && (targs[0].is_a?(QDL::Type::VarType) || (targs[0].is_a?(QDL::Type::GenericType) && targs[0].base.to_s == "ActiveRecord_Relation")) ? "Array<u> or ActiveRecord_Relation<u>" : "Array<u>"
    x = QDL::Globals.parser.scan_str "#T #{parse_string}"
    x
  else
    QDL::Globals.types[:array]
  end
end
QDL.type Array, 'self.plus_input', "(Array<QDL::Type::Type>) -> QDL::Type::Type", typecheck: :type_code, wrap: false


def Array.plus_output(trec, targs)
  case trec
  when QDL::Type::NominalType
    return QDL::Globals.types[:array]
  when QDL::Type::GenericType
    case targs[0]
    when QDL::Type::TupleType
      promoted = QDL.type_cast(targs[0], "QDL::Type::TupleType", force: true).promote
      param_union = QDL::Type::UnionType.new(promoted.params[0], trec.params[0])
      return QDL::Type::GenericType.new(trec.base, param_union)
    when QDL::Type::GenericType, QDL::Type::VarType
      return QDL::Globals.parser.scan_str "#T Array<u or t>"
    else
      ## targs[0] should just be array here
      return QDL::Globals.types[:array]
    end
  when QDL::Type::TupleType
    case targs[0]
    when QDL::Type::TupleType
      return QDL::Type::TupleType.new(*(trec.params + QDL.type_cast(targs[0], "QDL::Type::TupleType", force: true).params))
    when QDL::Type::GenericType
      promoted = trec.promote
      param_union = QDL::Type::UnionType.new(promoted.params[0], QDL.type_cast(targs[0], "QDL::Type::GenericType", force: true).params[0] )
      return QDL::Type::GenericType.new(QDL::Globals.types[:array], param_union)
    else
      ## targs[0] should just be Array here
      return QDL::Globals.types[:array]
    end
  end
end
QDL.type Array, 'self.plus_output', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", typecheck: :type_code, wrap: false

QDL.type :Array, :-, '(Array<u>) -> ``output_type(trec, targs, :-, :promoted_array, "Array<t>")``'
QDL.type :Array, :slice, '(Range<Integer>) -> ``output_type(trec, targs, :slice, :promoted_array, "Array<t>")``'
QDL.type :Array, :slice, '(Integer) -> ``output_type(trec, targs, :slice, :promoted_param, "t")``'
QDL.type :Array, :slice, '(Integer, Integer) -> ``output_type(trec, targs, :slice, :promoted_array, "Array<t>")``'
QDL.type :Array, :[]=, '(Integer, ``any_or_t(trec)``) -> ``assign_output(trec, targs)``'


def Array.assign_output(trec, targs)
  case trec
  when QDL::Type::TupleType
    case targs[0]
    when QDL::Type::SingletonType
      argval = QDL.type_cast(targs[0], "QDL::Type::SingletonType<Integer>", force: true).val
      if v = trec.params[argval]
        trec.params[argval] = QDL::Type::UnionType.new(v, targs[1])
        trec.params[argval] = Hash.weak_promote(trec.params[argval]) if QDL::Config.instance.weak_update_promote
        raise QDL::Typecheck::StaticTypeError, "Failed to mutate tuple: new tuple does not match previous constraints." unless trec.check_bounds(true)
        targs[1]
      else
        trec.params[QDL.type_cast(targs[0], "QDL::Type::SingletonType<Integer>", force: true).val] = targs[1]
        raise QDL::Typecheck::StaticTypeError, "Failed to mutate tuple: new tuple does not match previous constraints." unless trec.check_bounds(true)
        targs[1]
      end
    else
      raise "Unable to promote tuple." unless trec.promote!(targs[1])
      trec
    end
  else
    QDL::Globals.parser.scan_str "#T t"
  end
end
QDL.type Array, 'self.assign_output', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", typecheck: :type_code, wrap: false

QDL.type :Array, :[]=, '(Integer, Integer, ``any_or_t(trec)``) -> t'
QDL.type :Array, :[]=, '(Integer, Integer, ``any_or_t(trec)``) -> t'
QDL.type :Array, :[]=, '(Integer, Integer, ``QDL::Type::VarType.new(:self)``) -> self'


def Array.multi_assign_output(trec, targs)
  ## this method could get more precise, but it would require many more cases
  return QDL::Globals.types[:top] ### TODO: Figure out better solution. This is here to avoid promote!-ing when type does not actually match. 
=begin
  ## uncomment after figuring out above.
  case trec
  when QDL::Type::TupleType
    element = (if targs.length > 2 then targs[2] else targs[1] end)
    raise "Unable to promote tuple." unless trec.promote!(element)
    element
  else
    QDL::Globals.parser.scan_str "#T t"
  end
=end
end
QDL.type Array, 'self.multi_assign_output', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", typecheck: :type_code, wrap: false

QDL.type :Array, :[]=, '(Range<Integer>, ``any_or_t(trec)``) -> ``multi_assign_output(trec, targs)``'
QDL.type :Array, :assoc, '(t) -> Array<t>'
QDL.type :Array, :at, '(Integer) -> ``output_type(trec, targs, :at, :promoted_param, "t")``'
QDL.type :Array, :clear, '() -> self'
QDL.type :Array, :map, '() {(``promoted_or_t(trec)``) -> u } -> Array<u>'
QDL.type :Array, :map, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :map!, '() {(``promoted_or_t(trec)``) -> u} -> ``map_output(trec)``'

def Array.map_output(trec)
  case trec
  when QDL::Type::TupleType
    trec.params.map! { |e| QDL::Globals.parser.scan_str "#T u" } ## set each element to type u
    raise QDL::Typecheck::StaticTypeError, "Failed to mutate tuple: new tuple does not match previous constraints." unless trec.check_bounds(true)
    trec
  else
    QDL::Globals.parser.scan_str "#T Array<u>"
  end
end
QDL.type Array, 'self.map_output', "(QDL::Type::Type) -> QDL::Type::Type", typecheck: :type_code, wrap: false
  
QDL.type :Array, :map!, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :collect, '() {(``promoted_or_t(trec)``) -> u} -> Array<u>'
QDL.type :Array, :collect, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :combination, '(Integer) { (self) -> %any } -> self'
QDL.type :Array, :combination, '(Integer) -> Enumerator<self>'
QDL.type :Array, :push, '(``any_or_t(trec, true)``) -> ``append_push_output(trec, targs, :push)``'
QDL.type :Array, :compact, '() -> ``QDL::Type::GenericType.new(QDL::Globals.types[:array], promoted_or_t(trec))``'
QDL.type :Array, :compact!, '() -> ``promote_tuple!(trec)``'
QDL.type :Array, :concat, '(``promote_tuple(trec)``) -> ``promote_tuple!(trec)``' ## could be more precise here
QDL.type :Array, :count, '() -> ``output_type(trec, targs, :count, "Integer")``'
QDL.type :Array, :count, '(``any_or_t(trec)``) -> Integer'
QDL.type :Array, :count, '() { (``promoted_or_t(trec)``) -> %bool } -> Integer'
QDL.type :Array, :cycle, '(?Integer) { (``promoted_or_t(trec)``) -> %any } -> %any'
QDL.type :Array, :cycle, '(?Integer) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :delete, '(%any) -> ``promote_tuple!(trec); targs[0]``'
QDL.type :Array, :delete, '(u) { () -> v } -> ``promote_tuple!(trec); QDL::Globals.parser.scan_str "#T u or v"``'
QDL.type :Array, :delete_at, '(Integer) -> ``promote_tuple!(trec).params[0]``'
QDL.type :Array, :delete_if, '() { (``promoted_or_t(trec)``) -> %bool } -> ``promote_tuple!(trec)``'
QDL.type :Array, :delete_if, '() -> ``promote_tuple!(trec); QDL::Globals.parser.scan_str "#T Enumerator<t>"``'
QDL.type :Array, :drop, '(Integer) -> ``promote_tuple!(trec)``'
QDL.type :Array, :drop_while, '() { (``promoted_or_t(trec)``) -> %bool } -> ``promote_tuple!(trec)``'
QDL.type :Array, :drop_while, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :each, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :each, '() { (``promoted_or_t(trec)``) -> %any } -> self'
QDL.type :Array, :each, '() { (``each_arg(trec, 0)``, ``each_arg(trec, 1)``) -> %any } -> self' ## hack: if receiver is an array of arrays, then each block can take multiple args. not sure how to generalize this to arbitrary args, so for now I'm just getting it to work with two.
QDL.type :Array, :each, '() { (``each_arg(trec, 0)``, ``each_arg(trec, 1)``, ``each_arg(trec, 2)``, ``each_arg(trec, 3)``, ``each_arg(trec, 4)``, ``each_arg(trec, 5)``) -> %any } -> self' ## hack: if receiver is an array of arrays, then each block can take multiple args. not sure how to generalize this to arbitrary args, so for now I'm just getting it to work with two.

def Array.each_arg(trec, num)
  case trec
  when QDL::Type::TupleType
    if trec.params.all? { |t| t.is_a?(QDL::Type::TupleType) }
      first_params = QDL::Type::UnionType.new(*trec.params.map { |t| t.params[num] })
      first_params = first_params.canonical if first_params.is_a?(QDL::Type::UnionType)
      return first_params
    else
      return promoted_or_t(trec)
    end
  else
    if trec.params[0].is_a?(QDL::Type::TupleType)
      if trec.params[0].params.size > num
        return trec.params[0].params[num]
      else
        return QDL::Globals.types[:bot]
      end
    else
      return promoted_or_t(trec)
    end
  end
end


QDL.type :Array, :each_index, '() { (Integer) -> %any } -> self'
QDL.type :Array, :each_index, '() -> Enumerator<Integer>'
QDL.type :Array, :empty?, '() -> ``output_type(trec, targs, :empty?, "%bool")``'
QDL.type :Array, :fetch, '(Integer) -> ``output_type(trec, targs, :[], :promoted_param, "t")``'
QDL.type :Array, :fetch, '(Integer, %any) -> ``QDL::Type::UnionType.new(targs[1], output_type(trec, targs, :[], :promoted_param, "t"))``'
QDL.type :Array, :fetch, '(Integer) { (Integer) -> u } -> ``QDL::Type::UnionType.new(QDL::Globals.parser.scan_str("#T u"), output_type(trec, targs, :[], :promoted_param, "t"))``'
QDL.type :Array, :fill, '(``any_or_t(trec)``) -> ``fill_output(trec, targs)``'


def Array.fill_output(trec, targs)
  case trec
  when QDL::Type::TupleType
    trec.params.map! { |e|
      if QDL::Config.instance.weak_update_promote
        Hash.weak_promote(QDL::Type::UnionType.new(e, targs[0]).canonical)
      else
        QDL::Type::UnionType.new(e, targs[0]).canonical
      end
    }
    trec.check_bounds(true)
    trec
  else
    QDL::Globals.parser.scan_str "#T Array<t>"
  end
end
QDL.type Array, 'self.fill_output', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", typecheck: :type_code, wrap: false

QDL.type :Array, :fill, '(``promoted_or_t(trec)``, Integer, ?Integer) -> ``promote_tuple!(trec)``' ## can be more precise for this one, but would require many cases
QDL.type :Array, :fill, '(``promoted_or_t(trec)``, Range<Integer>) -> ``promote_tuple!(trec)``'
QDL.type :Array, :fill, '() { (Integer) -> ``promoted_or_t(trec)`` } -> ``promote_tuple!(trec)``'
QDL.type :Array, :fill, '(Integer, ?Integer) { (Integer) -> ``promoted_or_t(trec)`` } -> ``promote_tuple!(trec)``'
QDL.type :Array, :fill, '() { (Range<Integer>) -> ``promoted_or_t(trec)`` } -> ``promote_tuple!(trec)``'
QDL.type :Array, :flatten, '(?Integer) -> Array<%any>' # Can't give a more precise QDL.type
QDL.type :Array, :index, '(u) -> ``t = output_type(trec, targs, :index, "Integer", use_sing_val: false, nil_false_default: true)``'
QDL.type :Array, :index, '() { (``promoted_or_t(trec)``) -> %bool } -> Integer'
QDL.type :Array, :index, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :first, '() -> ``output_type(trec, targs, :first, :promoted_param, "t")``'
QDL.type :Array, :first, '(Integer) -> ``output_type(trec, targs, :first, :promoted_array, "Array<t>")``'
QDL.type :Array, :include?, '(%any) -> ``output_type(trec, targs, :include?, "%bool", use_sing_val: false, nil_false_default: true)``'


def Array.include_output(trec, targs)
  case trec
  when QDL::Type::TupleType
    case targs[0]
    when QDL::Type::SingletonType
      if trec.params.include?(targs[0])
        QDL::Globals.types[:true]
      else
        ## in this case, still can't say false because arg may be in tuple, but without singleton type.
        QDL::Globals.types[:bool]
      end
    else
      QDL::Globals.types[:bool]
    end
  else
    QDL::Globals.types[:bool]
  end
end
QDL.type Array, 'self.include_output', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", typecheck: :type_code, wrap: false


QDL.type :Array, :insert, '(Integer, ``promoted_or_t(trec)``) -> ``promote_tuple!(trec)``'
QDL.type :Array, :inspect, '() -> String'
QDL.type :Array, :join, '(?String) -> String'
QDL.type :Array, :keep_if, '() { (``promoted_or_t(trec)``) -> %bool } -> ``promote_tuple!(trec)``'
QDL.type :Array, :last, '() -> ``output_type(trec, targs, :last, :promoted_param, "t")``'
QDL.type :Array, :last, '(Integer) -> ``output_type(trec, targs, :last, :promoted_array, "Array<t>")``'
QDL.type :Array, :member?, '(%any) -> ``output_type(trec, targs, :member?, "%bool", use_sing_val: false, nil_false_default: true)``'
QDL.type :Array, :length, '() -> ``output_type(trec, targs, :length, "Integer")``'
QDL.type :Array, :permutation, '(?Integer) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :permuation, '(?Integer) { (``promote_tuple(trec)``) -> %any } -> ``promote_tuple(trec)``'
QDL.type :Array, :pop, '(Integer) -> ``promote_tuple!(trec)``'
QDL.type :Array, :pop, '() -> ``promote_tuple(trec); QDL::Globals.parser.scan_str "#T t"``'
QDL.type :Array, :product, '(*Array<u>) -> ``QDL::Type::GenericType.new(QDL::Globals.types[:array], QDL::Type::GenericType.new(QDL::Globals.types[:array], QDL::Type::UnionType.new(promoted_or_t(trec), QDL::Globals.parser.scan_str("#T u"))))``'
QDL.type :Array, :rassoc, '(u) -> ``promoted_or_t(trec)``'
QDL.type :Array, :reject, '() { (``promoted_or_t(trec)``) -> %bool } -> ``promote_tuple(trec)``'
QDL.type :Array, :reject, '() { () -> %bool } -> ``promote_tuple(trec)``'
QDL.type :Array, :reject, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :reject!, '() { (``promoted_or_t(trec)``) -> %bool } -> ``promote_tuple!(trec)``'
QDL.type :Array, :reject!, '() -> Enumerator<t>'
QDL.type :Array, :repeated_combination, '(Integer) { (``promote_tuple(trec)``) -> %any } -> ``promote_tuple(trec)``'
QDL.type :Array, :repeated_combination, '(Integer) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :repeated_permutation, '(Integer) { (``promote_tuple(trec)``) -> %any } -> ``promote_tuple(trec)``'
QDL.type :Array, :repeated_permutation, '(Integer) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :reverse, '() -> ``output_type(trec, targs, :reverse, :promoted_array, "Array<t>")``'
QDL.type :Array, :reverse!, '() -> ``reverse_output(trec)``'


def Array.reverse_output(trec)
  case trec
  when QDL::Type::TupleType
    rev = trec.params.reverse
    i = 0
    trec.params.map! { |e|
      un = QDL::Type::UnionType.new(e, rev[i]).canonical
      i = i + 1
      if QDL::Config.instance.weak_update_promote
        Hash.weak_promote(un)
      else
        un
      end
    }
    trec.check_bounds(true)
    trec
  else
    QDL::Globals.parser.scan_str "#T Array<t>"
  end
end
QDL.type Array, 'self.reverse_output', "(QDL::Type::Type) -> QDL::Type::Type", typecheck: :type_code, wrap: false

QDL.type :Array, :reverse_each, '() { (``promoted_or_t(trec)``) -> %any } -> self'
QDL.type :Array, :reverse_each, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :rindex, '(u) -> ``promoted_or_t(trec)``'
QDL.type :Array, :rindex, '() { (``promoted_or_t(trec)``) -> %bool } -> Integer'
QDL.type :Array, :rindex, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :rotate, '(?Integer) -> ``output_type(trec, targs, :rotate, :promoted_array, "Array<t>")``'
QDL.type :Array, :rotate!, '(?Integer) -> ``promote_tuple!(trec)``'
QDL.type :Array, :sample, '() -> ``promoted_or_t(trec)``'
QDL.type :Array, :sample, '(Integer) -> ``promote_tuple(trec)``'
QDL.type :Array, :sample, '({ random: [ rand: () -> Float ] }) -> ``promote_tuple(trec)``'
QDL.type :Array, :sample, '(Integer, { random: [ rand: () -> Float ] }) -> ``promote_tuple(trec)``'
QDL.type :Array, :select, '() { (``promoted_or_t(trec)``) -> %bool } -> ``promote_tuple(trec)``'
QDL.type :Array, :select, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :select!, '() { (``promoted_or_t(trec)``) -> %bool } -> ``promote_tuple!(trec)``'
QDL.type :Array, :select!, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :shift, '() -> ``promote_tuple!(trec); QDL::Globals.parser.scan_str "#T t"``'
QDL.type :Array, :shift, '(Integer) -> ``promote_tuple!(trec)``'
QDL.type :Array, :shuffle, '() -> ``promote_tuple(trec)``'
QDL.type :Array, :shuffle, '({ random: [ rand: () -> Float ] }) -> ``promote_tuple(trec)``'
QDL.type :Array, :shuffle!, '() -> ``promote_tuple!(trec)``'
QDL.type :Array, :shuffle!, '({ random: [ rand: () -> Float ] }) -> ``promote_tuple!(trec)``'
QDL.qdl_alias :Array, :size, :length
QDL.qdl_alias :Array, :slice, :[]
QDL.type :Array, :slice!, '(Range<Integer>) -> ``promote_tuple!(trec)``'
QDL.type :Array, :slice!, '(Integer, Integer) -> ``promote_tuple!(trec)``'
QDL.type :Array, :slice!, '(Integer or Float) -> ``promote_tuple!(trec); QDL::Globals.parser.scan_str "#T t"``'
QDL.type :Array, :sort, '() -> ``promote_tuple(trec)``'
QDL.type :Array, :sort, '() { (``promoted_or_t(trec)``, ``promoted_or_t(trec)``) -> Integer } -> ``promote_tuple(trec)``'
QDL.type :Array, :sort!, '() -> ``promote_tuple!(trec)``'
QDL.type :Array, :sort!, '() { (``promoted_or_t(trec)``,``promoted_or_t(trec)``) -> Integer } -> ``promote_tuple!(trec)``'
QDL.type :Array, :sort_by!, '() { (``promoted_or_t(trec)``) -> u } -> ``promote_tuple!(trec)``'
QDL.type :Array, :sort_by!, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :take, '(Integer) -> ``output_type(trec, targs, :take, :promoted_array, "Array<t>")``'
QDL.type :Array, :take_while, '() { (``promoted_or_t(trec)``) ->%bool } -> ``promote_tuple(trec)``'
QDL.type :Array, :take_while, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
QDL.type :Array, :to_a, '() -> self'
QDL.type :Array, :to_ary, '() -> self'
QDL.qdl_alias :Array, :to_s, :inspect
QDL.type :Array, :transpose, '() -> ``promote_tuple(trec)``'
QDL.type :Array, :uniq, '() -> ``promote_tuple(trec)``'
QDL.type :Array, :uniq, '() { (self) -> %any } -> ``promote_tuple(trec)``'
QDL.type :Array, :uniq!, '() -> ``promote_tuple!(trec)``'
QDL.type :Array, :uniq!, '() { (self) -> %any } -> ``promote_tuple!(trec)``'
QDL.type :Array, :unshift, '(``any_or_t(trec, true)``) -> ``promote_tuple!(trec)``'
QDL.type :Array, :values_at, '(*Integer) -> ``output_type(trec, targs, :values_at, :promoted_array, "Array<t>")``'
QDL.type :Array, :values_at, '(Range<Integer>) -> ``promote_tuple(trec)``'
#QDL.type :Array, :zip, '(*Array<z>) -> ``QDL::Type::GenericType.new(QDL::Globals.types[:array], QDL::Type::GenericType.new(QDL::Globals.types[:array], QDL::Type::UnionType.new(promoted_or_t(trec), QDL::Globals.parser.scan_str("#T z"))))``'
QDL.type :Array, :|, '(*Array<u>) -> ``QDL::Type::GenericType.new(QDL::Globals.types[:array], QDL::Type::UnionType.new(promoted_or_t(trec), QDL::Globals.parser.scan_str("#T u")))``'





######### Non-dependet types below #########

QDL.type :Array, :<<, '(t) -> Array<t>'
QDL.type :Array, :[], '(Range<Integer>) -> Array<t>'
QDL.type :Array, :[], '(Integer or Float) -> t'
QDL.type :Array, :[], '(Integer, Integer) -> Array<t>'
QDL.type :Array, :&, '(Array<u>) -> Array<t>'
QDL.type :Array, :*, '(Integer) -> Array<t>'
QDL.type :Array, :*, '(String) -> String'
QDL.type :Array, :+, '(Enumerable<u>) -> Array<u or t>'
QDL.type :Array, :+, '(Array<u>) -> Array<u or t>'
QDL.type :Array, :-, '(Array<u>) -> Array<u or t>'
QDL.type :Array, :slice, '(Range<Integer>) -> Array<t>'
QDL.type :Array, :slice, '(Integer) -> t'
QDL.type :Array, :slice, '(Integer, Integer) -> Array<t>'
QDL.type :Array, :[]=, '(Integer, t) -> t'
QDL.type :Array, :[]=, '(Integer, Integer, t) -> t'
# QDL.type :Array, :[]=, '(Integer, Integer, Array<t>) -> Array<t>'
# QDL.type :Array, :[]=, '(Range, Array<t>) -> Array<t>'
QDL.type :Array, :[]=, '(Range<Integer>, t) -> t'
QDL.type :Array, :assoc, '(t) -> Array<t>'
QDL.type :Array, :at, '(Integer) -> t'
QDL.type :Array, :clear, '() -> Array<t>'
QDL.type :Array, :map, '() {(t) -> u} -> Array<u>'
QDL.type :Array, :map, '() -> Enumerator<t>'
QDL.type :Array, :map!, '() {(t) -> u} -> Array<u>'
QDL.type :Array, :map!, '() -> Enumerator<t>'
QDL.type :Array, :collect, '() { (t) -> u } -> Array<u>'
QDL.type :Array, :collect, '() -> Enumerator<t>'
QDL.type :Array, :combination, '(Integer) { (Array<t>) -> %any } -> Array<t>'
QDL.type :Array, :combination, '(Integer) -> Enumerator<t>'
QDL.type :Array, :push, '(*t) -> Array<t>'
QDL.type :Array, :compact, '() -> Array<t>'
QDL.type :Array, :compact!, '() -> Array<t>'
QDL.type :Array, :concat, '(Array<t>) -> Array<t>'
QDL.type :Array, :count, '() -> Integer'
QDL.type :Array, :count, '(t) -> Integer'
QDL.type :Array, :count, '() { (t) -> %bool } -> Integer'
QDL.type :Array, :cycle, '(?Integer) { (t) -> %any } -> %any'
QDL.type :Array, :cycle, '(?Integer) -> Enumerator<t>'
QDL.type :Array, :delete, '(u) -> t'
QDL.type :Array, :delete, '(u) { () -> v } -> t or v'
QDL.type :Array, :delete_at, '(Integer) -> Array<t>'
QDL.type :Array, :delete_if, '() { (t) -> %bool } -> Array<t>'
QDL.type :Array, :delete_if, '() -> Enumerator<t>'
QDL.type :Array, :drop, '(Integer) -> Array<t>'
QDL.type :Array, :drop_while, '() { (t) -> %bool } -> Array<t>'
QDL.type :Array, :drop_while, '() -> Enumerator<t>'
QDL.type :Array, :each, '() -> Enumerator<t>'
QDL.type :Array, :each, '() { (t) -> %any } -> Array<t>'
QDL.type :Array, :each_index, '() { (Integer) -> %any } -> Array<t>'
QDL.type :Array, :each_index, '() -> Enumerator<t>'
QDL.type :Array, :empty?, '() -> %bool'
QDL.type :Array, :fetch, '(Integer) -> t'
QDL.type :Array, :fetch, '(Integer, u) -> u'
QDL.type :Array, :fetch, '(Integer) { (Integer) -> u } -> t or u'
QDL.type :Array, :fill, '(t) -> Array<t>'
QDL.type :Array, :fill, '(t, Integer, ?Integer) -> Array<t>'
QDL.type :Array, :fill, '(t, Range<Integer>) -> Array<t>'
QDL.type :Array, :fill, '() { (Integer) -> t } -> Array<t>'
QDL.type :Array, :fill, '(Integer, ?Integer) { (Integer) -> t } -> Array<t>'
QDL.type :Array, :fill, '(Range<Integer>) { (Integer) -> t } -> Array<t>'
QDL.type :Array, :flatten, '() -> Array<%any>' # Can't give a more precise QDL.type
QDL.type :Array, :index, '(u) -> Integer'
QDL.type :Array, :index, '() { (t) -> %bool } -> Integer'
QDL.type :Array, :index, '() -> Enumerator<t>'
QDL.type :Array, :first, '() -> t'
QDL.type :Array, :first, '(Integer) -> Array<t>'
QDL.type :Array, :include?, '(u) -> %bool'
QDL.type :Array, :initialize, '() -> self'
QDL.type :Array, :initialize, '(Integer) -> self'
QDL.type :Array, :initialize, '(Integer, t) -> self<t>'
QDL.type :Array, :initialize, '(Array<k>) -> self<k>'
QDL.type :Array, :initialize, '(Integer) { (?Integer) -> t } -> self<t>'
QDL.type :Array, :insert, '(Integer, *t) -> Array<t>'
QDL.type :Array, :inspect, '() -> String'
QDL.type :Array, :join, '(?String) -> String'
QDL.type :Array, :keep_if, '() { (t) -> %bool } -> Array<t>'
QDL.type :Array, :last, '() -> t'
QDL.type :Array, :last, '(Integer) -> Array<t>'
QDL.type :Array, :member?, '(u) -> %bool'
QDL.type :Array, :length, '() -> Integer'
QDL.type :Array, :pack, "(String) -> String"
QDL.type :Array, :permutation, '(?Integer) -> Enumerator<t>'
QDL.type :Array, :permutation, '(?Integer) { (Array<t>) -> %any } -> Array<t>'
QDL.type :Array, :pop, '(Integer) -> Array<t>'
QDL.type :Array, :pop, '() -> t'
QDL.type :Array, :product, '(*Array<u>) -> Array<Array<t or u>>'
QDL.type :Array, :rassoc, '(u) -> t'
QDL.type :Array, :reject, '() { (t) -> %bool } -> Array<t>'
QDL.type :Array, :reject, '() -> Enumerator<t>'
QDL.type :Array, :reject!, '() { (t) -> %bool } -> Array<t>'
QDL.type :Array, :reject!, '() -> Enumerator<t>'
QDL.type :Array, :repeated_combination, '(Integer) { (Array<t>) -> %any } -> Array<t>'
QDL.type :Array, :repeated_combination, '(Integer) -> Enumerator<t>'
QDL.type :Array, :repeated_permutation, '(Integer) { (Array<t>) -> %any } -> Array<t>'
QDL.type :Array, :repeated_permutation, '(Integer) -> Enumerator<t>'
QDL.type :Array, :reverse, '() -> Array<t>'
QDL.type :Array, :reverse!, '() -> Array<t>'
QDL.type :Array, :reverse_each, '() { (t) -> %any } -> Array<t>'
QDL.type :Array, :reverse_each, '() -> Enumerator<t>'
QDL.type :Array, :rindex, '(u) -> t'
QDL.type :Array, :rindex, '() { (t) -> %bool } -> Integer'
QDL.type :Array, :rindex, '() -> Enumerator<t>'
QDL.type :Array, :rotate, '(?Integer) -> Array<t>'
QDL.type :Array, :rotate!, '(?Integer) -> Array<t>'
QDL.type :Array, :sample, '() -> t'
QDL.type :Array, :sample, '(Integer) -> Array<t>'
QDL.type :Array, :select, '() { (t) -> %bool } -> Array<t>'
QDL.type :Array, :select, '() -> Enumerator<t>'
QDL.type :Array, :select!, '() { (t) -> %bool } -> Array<t>'
QDL.type :Array, :select!, '() -> Enumerator<t>'
QDL.type :Array, :shift, '() -> t'
QDL.type :Array, :shift, '(Integer) -> Array<t>'
QDL.type :Array, :shuffle, '() -> Array<t>'
QDL.type :Array, :shuffle!, '() -> Array<t>'
QDL.type :Array, :slice!, '(Range<Integer>) -> Array<t>'
QDL.type :Array, :slice!, '(Integer, Integer) -> Array<t>'
QDL.type :Array, :slice!, '(Integer or Float) -> t'
QDL.type :Array, :sort, '() -> Array<t>'
QDL.type :Array, :sort, '() { (t,t) -> Integer } -> Array<t>'
QDL.type :Array, :sort!, '() -> Array<t>'
QDL.type :Array, :sort!, '() { (t,t) -> Integer } -> Array<t>'
QDL.type :Array, :sort_by!, '() { (t) -> u } -> Array<t>'
QDL.type :Array, :sort_by!, '() -> Enumerator<t>'
QDL.type :Array, :take, '(Integer) -> Array<t>'
QDL.type :Array, :take_while, '() { (t) ->%bool } -> Array<t>'
QDL.type :Array, :take_while, '() -> Enumerator<t>'
QDL.type :Array, :to_a, '() -> Array<t>'
QDL.type :Array, :to_ary, '() -> Array<t>'
QDL.type :Array, :transpose, '() -> Array<t>'
QDL.type :Array, :uniq, '() -> Array<t>'
QDL.type :Array, :uniq!, '() -> Array<t>'
QDL.type :Array, :unshift, '(*t) -> Array<t>'
QDL.type :Array, :values_at, '(*Range<Integer> or Integer) -> Array<t>'
QDL.type :Array, :zip, '(*Array<u>) -> Array<Array<t or u>>'
QDL.type :Array, :|, '(Array<u>) -> Array<t or u>'
