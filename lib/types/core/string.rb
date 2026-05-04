QDL.nowrap :String

def String.output_type(trec, targs, meth, type)
  case trec
  when QDL::Type::PreciseStringType
    return QDL::Globals.parser.scan_str "#T #{type}" unless trec.vals.size == 1 ## Can maybe get more precise than this for some methods, but in most cases we have to sacrifice precision. Might return to this.
    if targs.empty?
      res = trec.vals[0].send(meth)
    elsif targs.size == 1
      case targs[0]
      when QDL::Type::SingletonType
        res = trec.vals[0].send(meth, targs[0].val)
      when QDL::Type::PreciseStringType
        res = trec.vals[0].send(meth, targs.vals[0])
      else
        return QDL::Globals.parser.scan_str "#T #{type}"
      end
    elsif targs.size > 1 && targs.all? { |a| a.is_a?(QDL::Type::SingletonType) }
      vals = targs.map { |t| t.val }
      to_type(trec.vals[0].send(meth, *vals))
    else
      #raise "not yet implemented with method #{meth} and trec #{trec} and targs #{targs} and type #{type}"
      QDL::Globals.parser.scan_str "#T #{type}"
    end
    to_type(res)
  else
    QDL::Globals.parser.scan_str "#T #{type}"
  end
end

QDL.type String, 'self.output_type', "(QDL::Type::Type, Array<QDL::Type::Type>, Symbol, String) -> QDL::Type::Type"

def String.to_type(v)
  case v
  when QDL::Type::Type
    v
  when Array
    QDL::Type::TupleType.new(*(v.map { |i| to_type(i) }))
  when String
    QDL::Type::PreciseStringType.new(v)
  when Symbol, Integer, Float, Class, TrueClass, FalseClass
    QDL::Type::SingletonType.new(v)
  else
    QDL::Type::NominalType.new(v.class)
  end
end

QDL.type String, 'self.to_type', "(%any) -> QDL::Type::Type"

def String.any_string(a)
  case a
  when QDL::Type::PreciseStringType
    a
  else
    QDL::Globals.types[:string]
  end
end

QDL.type String, 'self.any_string', "(%any) -> QDL::Type::Type"

def String.string_promote!(trec)
  case trec
  when QDL::Type::PreciseStringType
    raise "Unable to promote string #{trec}." unless trec.promote!
    trec
  else
    QDL::Globals.types[:string]
  end
end

QDL.type String, 'self.string_promote!', "(%any) -> QDL::Type::Type"


QDL.type :String, :initialize, '(?String str) -> self new_str'
QDL.type :String, 'self.try_convert', '(Object obj) -> String or nil new_string'
QDL.type :String, :%, '(``targs[0]``) -> ``output_type(trec, targs, :%, "String")``'
QDL.type :String, :*, '(Numeric) -> ``output_type(trec, targs, :*, "String")``'
QDL.type :String, :-@, "() -> ``output_type(trec, targs, :-@, 'String')``"

def String.plus_output(trec, targs)
  if trec.is_a?(QDL::Type::PreciseStringType) && targs[0].is_a?(QDL::Type::PreciseStringType)
  then QDL::Type::PreciseStringType.new(*(trec.vals+targs[0].vals))
  else QDL::Globals.types[:string]
  end
end

QDL.type String, 'self.plus_output', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type"


QDL.type :String, :+, '(``any_string(targs[0])``) -> ``plus_output(trec, targs)``'
QDL.type :String, :<<, '(Object) -> ``append_output(trec, targs)``'

def String.append_output(trec, targs)
  if trec.is_a?(QDL::Type::PreciseStringType) && targs[0].is_a?(QDL::Type::PreciseStringType)
    targs[0].vals.each { |v|
      if trec.vals.last.is_a?(String) && v.is_a?(String)
        trec.vals.last << v
      else
        trec.vals << v
      end
    }
    raise QDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds(true)
    trec
  elsif trec.is_a?(QDL::Type::PreciseStringType)
    trec.promote!
    trec
  else
    QDL::Globals.types[:string]
  end
end

QDL.type String, 'self.append_output', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type"

QDL.type :String, :<=>, '(String) -> ``output_type(trec, targs, :<=>, "Integer")``'
QDL.type :String, :==, '(%any) -> ``output_type(trec, targs, :==, "%bool")``'
QDL.type :String, :===, '(%any) -> ``output_type(trec, targs, :===, "%bool")``'
QDL.type :String, :=~, '(Object) -> ``output_type(trec, targs, :=~, "Integer")``', wrap: false # Wrapping this messes up $1 etc
QDL.type :String, :[], '(Integer, ?Integer) -> ``output_type(trec, targs, :[], "String")``'
QDL.type :String, :[], '(Range<Integer> or Regexp) -> ``output_type(trec, targs, :[], "String")``'
QDL.type :String, :[], '(Regexp, Integer) -> ``output_type(trec, targs, :[], "String")``'
QDL.type :String, :[], '(Regexp, String) -> ``output_type(trec, targs, :[], "String")``'
QDL.type :String, :[], '(String) -> ``output_type(trec, targs, :[], "String")``'
QDL.type :String, :ascii_only?, '() -> ``output_type(trec, targs, :ascii_only?, "%bool")``'
QDL.type :String, :b, '() -> ``output_type(trec, targs, :b, "String")``'
QDL.type :String, :bytes, '() -> ``output_type(trec, targs, :bytes, "Array<Integer>")``' 
QDL.type :String, :bytesize, '() -> ``output_type(trec, targs, :bytesize, "Integer")``'
QDL.type :String, :byteslice, '(Integer, ?Integer) -> ``output_type(trec, targs, :byteslice, "String")``'
QDL.type :String, :byteslice, '(Range<Integer>) -> ``output_type(trec, targs, :byteslice, "String")``'
QDL.type :String, :capitalize, '() -> ``output_type(trec, targs, :capitalize, "String")``'
QDL.type :String, :capitalize!, '() -> ``cap_down_output(trec, :capitalize!)``'
def String.cap_down_output(trec, meth)
  case trec
  when QDL::Type::PreciseStringType
    trec.vals.each { |v| v.send(meth) if v.is_a?(String) }
    raise QDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds(true)
    trec
  else
    QDL::Globals.types[:string]
  end      
end

QDL.type String, 'self.cap_down_output', "(QDL::Type::Type, Symbol) -> QDL::Type::Type"
  
QDL.type :String, :casecmp, '(String) -> ``output_type(trec, targs, :casecmp, "Integer")``'
QDL.type :String, :center, '(Integer, ?String) -> ``output_type(trec, targs, :center, "String")``'
QDL.type :String, :chars, '() -> ``output_type(trec, targs, :chars, "Array<String>")``'  #deprecated
QDL.type :String, :chomp, '(?String) -> ``output_type(trec, targs, :chomp, "String")``'
QDL.type :String, :chomp!, '(?String) -> ``string_promote!(trec)``' ## chomp! depends on the value of $/, which is hard to reason about during type checking. So, keeping this imprecise.
QDL.type :String, :chop, '() -> ``output_type(trec, targs, :chop, "String")``'
QDL.type :String, :chop!, '() -> ``chop_output(trec)``'

def String.chop_output(trec)
  case trec
  when QDL::Type::PreciseStringType
    if trec.vals.last.is_a?(String)
      trec.vals.last.chop!
      raise QDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds(true)
      trec
    else
      trec.promote!
      trec
    end
  else
    QDL::Globals.types[:string]
  end
end

QDL.type String, 'self.chop_output', "(QDL::Type::Type) -> QDL::Type::Type"

QDL.type :String, :chr, '() -> ``output_type(trec, targs, :chr, "String")``'
QDL.type :String, :clear, '() -> ``clear_output(trec)``'

def String.clear_output(trec)
  case trec
  when QDL::Type::PreciseStringType
    trec.vals = [""]
    raise QDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds(true)
    trec
  else
    QDL::Type::PreciseStringType.new("")
  end
end

QDL.type String, 'self.clear_output', "(QDL::Type::Type) -> QDL::Type::Type"

QDL.type :String, :codepoints, '() -> ``output_type(trec, targs, :codepoints, "Array<Integer>")``'
QDL.type :String, :concat, '(Integer or Object) -> ``append_output(trec, targs)``'
QDL.type :String, :count, '(String, *String) -> ``output_type(trec, targs, :count, "Integer")``'
QDL.type :String, :crypt, '(String) -> ``output_type(trec, targs, :crypt, "String")``'
QDL.type :String, :delete, '(String, *String) -> ``output_type(trec, targs, :delete, "String")``'
QDL.type :String, :delete!, '(String, *String) -> ``string_promote!(trec)``'
QDL.type :String, :downcase, '() -> ``output_type(trec, targs, :downcase, "String")``'
QDL.type :String, :downcase!, '() -> ``cap_down_output(trec, :downcase!)``'
QDL.type :String, :dump, '() -> ``output_type(trec, targs, :dump, "String")``'
QDL.type :String, :each_byte, '() {(Integer) -> %any} -> String'
QDL.type :String, :each_byte, '() -> Enumerator'
QDL.type :String, :each_char, '() {(String) -> %any} -> String'
QDL.type :String, :each_char, '() -> Enumerator'
QDL.type :String, :each_codepoint, '() {(Integer) -> %any} -> String'
QDL.type :String, :each_codepoint, '() -> Enumerator'
QDL.type :String, :each_line, '(?String) {(String) -> %any} -> String'
QDL.type :String, :each_line, '(?String) -> Enumerator'
QDL.type :String,  :empty?, '() ->``output_type(trec, targs, :empty?, "%bool")``'
# QDL.type :String, :encode, '(?Encoding, ?Encoding, *Symbol) -> String' # TODO: fix Hash arg:String,
# QDL.type :String, :encode!, '(Encoding, ?Encoding, *Symbol) -> String'
QDL.type :String, :encoding, '() -> Encoding'
QDL.type :String, :end_with?, '(*String) -> ``output_type(trec, targs, :end_with?, "%bool")``'
QDL.type :String, :eql?, '(String) -> ``output_type(trec, targs, :eql?, "%bool")``'
QDL.type :String, :force_encoding, '(String or Encoding) -> String'
QDL.type :String, :getbyte, '(Integer) -> ``output_type(trec, targs, :getbyte, "Integer")``'
QDL.type :String, :gsub, '(Regexp or String, String) -> ``output_type(trec, targs, :gsub, "String")``', wrap: false # Can't wrap these:String, , since they mess with $1 etc
QDL.type :String, :gsub, '(Regexp or String, Hash) -> ``output_type(trec, targs, :gsub, "String")``'
QDL.type :String, :gsub, '(Regexp or String, String) -> ``output_type(trec, targs, :gsub, "String")``', wrap: false
QDL.type :String, :gsub, '(Regexp or String) {(String) -> %any } -> ``output_type(trec, targs, :gsub, "String")``'
QDL.type :String, :gsub, '(Regexp or String) {() -> %any } -> ``output_type(trec, targs, :gsub, "String")``'

QDL.type :String, :gsub, '(Regexp or String, String) -> ``output_type(trec, targs, :gsub, "String")``', wrap: false
QDL.type :String, :gsub, '(Regexp or String) ->  ``output_type(trec, targs, :gsub, "String")``'
QDL.type :String, :gsub!, '(Regexp or String, String) -> ``string_promote!(trec)``', wrap: false
QDL.type :String, :gsub!, '(Regexp or String) {(String) -> %any } -> ``string_promote!(trec)``', wrap: false
QDL.type :String, :gsub!, '(Regexp or String) {() -> %any } -> ``string_promote!(trec)``', wrap: false
QDL.type :String, :gsub!, '(Regexp or String) -> ``string_promote!(trec); QDL::Type::NominalType.new(Enumerator)``', wrap: false
QDL.type :String, :hash, '() -> Integer'
QDL.type :String, :hex, '() -> ``output_type(trec, targs, :getbyte, "Integer")``'
QDL.type :String, :include?, '(String) -> ``output_type(trec, targs, :include?, "%bool")``'
QDL.type :String, :index, '(Regexp or String, ?Integer) -> ``output_type(trec, targs, :index, "Integer")``'
QDL.type :String, :replace, '(String) -> ``replace_output(trec, targs)``'

def String.replace_output(trec, targs)
  case trec
  when QDL::Type::PreciseStringType
    case targs[0]
    when QDL::Type::PreciseStringType
      trec.vals = targs[0].vals
      raise QDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds(true)
      trec
    else
      raise QDL::Typecheck::StaticTypeError, "Failed to promote string #{trec}." unless trec.promote!
      trec
    end      
  else
    trec
  end
end

QDL.type String, 'self.replace_output', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type"

QDL.type :String, :insert, '(Integer, String) -> String' ## TODO

def String.insert_output(trec, targs)
  case trec
  when QDL::Type::PreciseStringType
    if targs[0].is_a?(QDL::Type::SingletonType) && targs[1].is_a?(QDL::Type::PreciseStringType) && targs[1].all? { |v| v.is_a?(String) } && trec.vals.all? { |v| v.is_a?(String) }
      rec_str = trec.vals.join
      arg_int = targs[0].val
      arg_str = targs[1].vals.join
      trec.vals = [rec_str.insert(arg_int, arg_str)]
      raise QDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds(true)
      trec
    else
      raise QDL::Typecheck::StaticTypeError, "Failed to promote string #{trec}." unless trec.promote!
      trec
    end
  else
    trec
  end
end

QDL.type String, 'self.insert_output', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type"

QDL.type :String, :inspect, '() -> ``output_type(trec, targs, :inspect, "String")``'
QDL.type :String, :intern, '() -> ``output_type(trec, targs, :intern, "Symbol")``'
QDL.type :String, :length, '() -> ``output_type(trec, targs, :length, "Integer")``'
QDL.type :String, :lines, '(?String) -> ``output_type(trec, targs, :lines, "Array<String>")``'
QDL.type :String, :ljust, '(Integer, ?String) -> ``output_type(trec, targs, :ljust, "String")``'
QDL.type :String, :lstrip, '() -> ``output_type(trec, targs, :getbyte, "String")``'
QDL.type :String, :lstrip!, '() -> ``lrstrip_output(trec, :lstrip!)``' ## TODO

def String.lrstrip_output(trec, meth)
  check = (if meth == :lstrip! then :start_with? elsif meth == :rstrip! then :end_with? else raise "unexpected val #{meth}" end)
  case trec
  when QDL::Type::PreciseStringType
    if trec.vals[0].is_a?(String)
      if trec.vals[0].send(check, " ")
        trec.vals[0].send(meth)
        raise QDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds(true)
        trec        
      else
        trec
      end
    else
      raise QDL::Typecheck::StaticTypeError, "Failed to promote string #{trec}." unless trec.promote!
      trec
    end
  else
    trec
  end
end

QDL.type String, 'self.lrstrip_output', "(QDL::Type::Type, Symbol) -> QDL::Type::Type"

QDL.type :String, :match, '(Regexp or String) -> MatchData'
QDL.type :String, :match, '(Regexp or String, Integer) -> MatchData'
QDL.type :String, :next, '() -> ``output_type(trec, targs, :next, "String")``'
QDL.type :String, :next!, '() -> ``mutate_output(trec, :next!)``' ## TODO

def String.mutate_output(trec, meth)
  case trec
  when QDL::Type::PreciseStringType
    if trec.vals.all? { |v| v.is_a?(String) }
      trec.vals = [trec.vals.join.send(meth)]
      raise QDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds(true)
      trec        
    else
      raise QDL::Typecheck::StaticTypeError, "Failed to promote string #{trec}." unless trec.promote!
      trec
    end
  else
    trec
  end
end

QDL.type String, 'self.mutate_output', "(QDL::Type::Type, Symbol) -> QDL::Type::Type"


QDL.type :String, :oct, '() -> ``output_type(trec, targs, :oct, "Integer")``'
QDL.type :String, :ord, '() -> ``output_type(trec, targs, :ord, "Integer")``'
QDL.type :String, :partition, '(Regexp or String) -> ``output_type(trec, targs, :partition, "Array<String>")``'
QDL.type :String, :prepend, '(String) -> ``output_type(trec, targs, :prepend, "String")``'
QDL.type :String, :reverse, '() -> ``output_type(trec, targs, :reverse, "String")``'
QDL.type :String, :rindex, '(String or Regexp, ?Integer) -> ``output_type(trec, targs, :rindex, "Integer")``'
QDL.type :String, :rjust, '(Integer, ?String) -> ``output_type(trec, targs, :rjust, "String")``'
QDL.type :String, :rpartition, '(String or Regexp) -> ``output_type(trec, targs, :rpartition, "Array<String>")``'
QDL.type :String, :rstrip, '() -> ``output_type(trec, targs, :rstrip, "String")``'
QDL.type :String, :rstrip!, '() -> ``lrstrip_output(trec, :rstrip!)``'
QDL.type :String, :scan, '(Regexp or String) -> ``output_type(trec, targs, :scan, "Array<String or Array<String>>")``', wrap: false # :String, Can't wrap or screws up last_match
QDL.type :String, :scan, '(Regexp or String) {() -> %any} -> ``output_type(trec, targs, :scan, "Array<String or Array<String>>")``', wrap: false
QDL.type :String, :scan, '(Regexp or String) {(String) -> %any} -> ``output_type(trec, targs, :scan, "Array<String or Array<String>>")``', wrap: false
QDL.type :String, :scan, '(Regexp or String) {(String, String) -> %any} -> ``output_type(trec, targs, :scan, "Array<String or Array<String>>")``', wrap: false
QDL.type :String, :scan, '(Regexp or String) {(*String) -> %any} -> ``output_type(trec, targs, :scan, "Array<String or Array<String>>")``', wrap: false
QDL.type :String, :scrub, '(?String) -> ``output_type(trec, targs, :scrub, "String")``'
QDL.type :String, :scrub, '(?String) {(%any) -> %any} -> String'
QDL.type :String, :scrub!, '(?String) -> ``string_promote!(trec)``'
QDL.type :String, :scrub!, '(?String) {(%any) -> %any} -> ``string_promote!(trec)``'
QDL.type :String, :size, '() -> ``output_type(trec, targs, :size, "Integer")``'
QDL.qdl_alias :String, :slice, :[]
QDL.type :String, :slice!, '(Integer, ?Integer) -> ``string_promote!(trec)``'
QDL.type :String, :slice!, '(Range<Integer> or Regexp) -> ``string_promote!(trec)``'
QDL.type :String, :slice!, '(Regexp, Integer) -> ``string_promote!(trec)``'
QDL.type :String, :slice!, '(Regexp, String) -> ``string_promote!(trec)``'
QDL.type :String, :slice!, '(String) -> ``string_promote!(trec)``'
QDL.type :String, :split, '(?(Regexp or String), ?Integer) -> ``output_type(trec, targs, :split, "Array<String>")``'
QDL.type :String, :split, '(?Integer) -> ``output_type(trec, targs, :split, "Array<String>")``'
QDL.type :String, :squeeze, '(?String) -> ``output_type(trec, targs, :squeeze, "String")``'
QDL.type :String, :squeeze!, '(?String) -> ``mutate_output(trec, :squeeze!)``'
QDL.type :String, :start_with?, '(* String) -> ``output_type(trec, targs, :start_with?, "%bool")``'
QDL.type :String, :strip, '() -> ``output_type(trec, targs, :strip, "String")``'
QDL.type :String, :strip!, '() -> ``mutate_output(trec, :strip!)``'
QDL.type :String, :sub, '(Regexp or String, String or Hash) -> ``output_type(trec, targs, :sub, "String")``', wrap: false # Can't wrap these, since they mess with $1 etc
QDL.type :String, :sub, '(Regexp or String) {(String) -> %any} -> ``output_type(trec, targs, :sub, "String")``', wrap: false
QDL.type :String, :sub, '(Regexp or String) {() -> %any} -> ``output_type(trec, targs, :sub, "String")``', wrap: false
QDL.type :String, :sub!, '(Regexp or String, String) -> ``string_promote!(trec)``', wrap: false
QDL.type :String, :sub!, '(Regexp or String) {(String) -> %any} -> ``string_promote!(trec)``', wrap: false
QDL.type :String, :succ, '() -> ``output_type(trec, targs, :succ, "String")``'
QDL.type :String, :sum, '(?Integer) -> ``output_type(trec, targs, :sum, "Integer")``'
QDL.type :String, :swapcase, '() -> ``output_type(trec, targs, :swapcase, "String")``'
QDL.type :String, :swapcase!, '() -> ``mutate_output(trec, :swapcase!)``'
QDL.type :String, :to_c, '() -> Complex'
QDL.type :String, :to_f, '() -> ``output_type(trec, targs, :to_f, "Float")``'
QDL.type :String, :to_i, '(?Integer) -> ``output_type(trec, targs, :to_i, "Integer")``'
QDL.type :String, :to_r, '() -> Rational'
QDL.type :String, :to_s, '() -> self'
QDL.type :String, :to_str, '() -> self'
QDL.type :String, :to_sym, '() -> ``output_type(trec, targs, :to_sym, "Symbol")``'
QDL.type :String, :tr, '(String, String) -> ``output_type(trec, targs, :tr, "String")``'
QDL.type :String, :tr!, '(String, String) -> ``string_promote!(trec)``'
QDL.type :String, :tr_s, '(String, String) -> ``output_type(trec, targs, :tr_s, "String")``'
QDL.type :String, :tr_s!, '(String, String) -> ``string_promote!(trec)``'
QDL.type :String, :unpack, '(String) -> ``output_type(trec, targs, :unpack, "Array<Integer or String>")``'
QDL.type :String, :upcase, '() -> ``output_type(trec, targs, :upcase, "String")``'
QDL.type :String, :upcase!, '() -> ``mutate_output(trec, :upcase!)``'
QDL.type :String, :upto, '(String, ?bool) -> Enumerator'
QDL.type :String, :upto, '(String, ?bool) {(String) -> %any } -> String'
QDL.type :String, :valid_encoding?, '() -> ``output_type(trec, targs, :valid_encoding?, "%bool")``'











### non-dependent types






QDL.type :String, :initialize, '(?String str) -> self new_str'
QDL.type :String, :'self.try_convert', '(Object obj) -> String or nil new_string'
QDL.type :String, :%, '(Object) -> String'
QDL.type :String, :*, '(Integer) -> String'
QDL.type :String, :+, '(String) -> String'
QDL.type :String, :<<, '(Object) -> String'
QDL.type :String, :<=>, '(String other) -> Integer or nil ret'
QDL.type :String, :==, '(%any) -> %bool'
QDL.type :String, :===, '(%any) -> %bool'
QDL.type :String, :=~, '(Object) -> Integer or nil', wrap: false # Wrapping this messes up $1 etc
QDL.type :String, :[], '(Integer, ?Integer) -> String or nil'
QDL.type :String, :[], '(Range<Integer> or Regexp) -> String or nil'
QDL.type :String, :[], '(Regexp, Integer) -> String or nil'
QDL.type :String, :[], '(Regexp, String) -> String or nil'
QDL.type :String, :[], '(String) -> String or nil'
QDL.type :String, :ascii_only?, '() -> %bool'
QDL.type :String, :b, '() -> String'
QDL.type :String, :bytes, '() -> Array' # TODO: bindings to parameterized (vars)
QDL.type :String, :bytesize, '() -> Integer'
QDL.type :String, :byteslice, '(Integer, ?Integer) -> String or nil'
QDL.type :String, :byteslice, '(Range<Integer>) -> String or nil'
QDL.type :String, :capitalize, '() -> String'
QDL.type :String, :capitalize!, '() -> String or nil'
QDL.type :String, :casecmp, '(String) -> nil or Integer'
QDL.type :String, :center, '(Integer, ?String) -> String'
QDL.type :String, :chars, '() -> Array<String>'  #deprecated
QDL.type :String, :chomp, '(?String) -> String'
QDL.type :String, :chomp!, '(?String) -> String or nil'
QDL.type :String, :chop, '() -> String'
QDL.type :String, :chop!, '() -> String or nil'
QDL.type :String, :chr, '() -> String'
QDL.type :String, :clear, '() -> String'
QDL.type :String, :codepoints, '() -> Array<Integer>' # TODO
QDL.type :String, :codepoints, '() {(?%any) -> %any} -> Array<Integer>' # TODO
QDL.type :String, :concat, '(Integer or Object) -> String'
QDL.type :String, :count, '(String, *String) -> Integer'
QDL.type :String, :crypt, '(String) -> String'
QDL.type :String, :delete, '(String, *String) -> String'
QDL.type :String, :delete!, '(String, *String) -> String or nil'
QDL.type :String, :downcase, '() -> String'
QDL.type :String, :downcase!, '() -> String or nil'
QDL.type :String, :dump, '() -> String'
QDL.type :String, :each_byte, '() {(Integer) -> %any} -> String'
QDL.type :String, :each_byte, '() -> Enumerator'
QDL.type :String, :each_char, '() {(String) -> %any} -> String'
QDL.type :String, :each_char, '() -> Enumerator'
QDL.type :String, :each_codepoint, '() {(Integer) -> %any} -> String'
QDL.type :String, :each_codepoint, '() -> Enumerator'
QDL.type :String, :each_line, '(?String) {(String) -> %any} -> String'
QDL.type :String, :each_line, '(?String) -> Enumerator'
QDL.type :String,  :empty?, '() -> %bool'
# QDL.type :String, :encode, '(?Encoding, ?Encoding, *Symbol) -> String' # TODO: fix Hash arg:String,
# QDL.type :String, :encode!, '(Encoding, ?Encoding, *Symbol) -> String'
QDL.type :String, :encoding, '() -> Encoding'
QDL.type :String, :end_with?, '(*String) -> %bool'
QDL.type :String, :eql?, '(String) -> %bool'
QDL.type :String, :force_encoding, '(String or Encoding) -> String'
QDL.type :String, :getbyte, '(Integer) -> Integer or nil'
QDL.type :String, :gsub, '(Regexp or String, String) -> String', wrap: false # Can't wrap these:String, , since they mess with $1 etc
QDL.type :String, :gsub, '(Regexp or String, Hash) -> String', wrap: false
QDL.type :String, :gsub, '(Regexp or String) {(String) -> %any } -> String', wrap: false
QDL.type :String, :gsub, '(Regexp or String) ->  Enumerator', wrap: false
QDL.type :String, :gsub, '(Regexp or String) -> String', wrap: false
QDL.type :String, :gsub!, '(Regexp or String, String) -> String or nil', wrap: false
QDL.type :String, :gsub!, '(Regexp or String) {(String) -> %any } -> String or nil', wrap: false
QDL.type :String, :gsub!, '(Regexp or String) -> Enumerator', wrap: false
QDL.type :String, :hash, '() -> Integer'
QDL.type :String, :hex, '() -> Integer'
QDL.type :String, :include?, '(String) -> %bool'
QDL.type :String, :index, '(Regexp or String, ?Integer) -> Integer or nil'
QDL.type :String, :replace, '(String) -> String'
QDL.type :String, :insert, '(Integer, String) -> String'
QDL.type :String, :inspect, '() -> String'
QDL.type :String, :intern, '() -> Symbol'
QDL.type :String, :length, '() -> Integer'
QDL.type :String, :lines, '(?String) -> Array<String>'
QDL.type :String, :ljust, '(Integer, ?String) -> String' # TODO
QDL.type :String, :lstrip, '() -> String'
QDL.type :String, :lstrip!, '() -> String or nil'
QDL.type :String, :match, '(Regexp or String) -> MatchData'
QDL.type :String, :match, '(Regexp or String, Integer) -> MatchData'
QDL.type :String, :next, '() -> String'
QDL.type :String, :next!, '() -> String'
QDL.type :String, :oct, '() -> Integer'
QDL.type :String, :ord, '() -> Integer'
QDL.type :String, :partition, '(Regexp or String) -> Array<String>'
QDL.type :String, :prepend, '(String) -> String'
QDL.type :String, :reverse, '() -> String'
QDL.type :String, :rindex, '(String or Regexp, ?Integer) -> Integer or nil' # TODO
QDL.type :String, :rjust, '(Integer, ?String) -> String' # TODO
QDL.type :String, :rpartition, '(String or Regexp) -> Array<String>'
QDL.type :String, :rstrip, '() -> String'
QDL.type :String, :rstrip!, '() -> String'
QDL.type :String, :scan, '(Regexp or String) -> Array<String or Array<String>>', wrap: false # :String, Can't wrap or screws up last_match
QDL.type :String, :scan, '(Regexp or String) {(*%any) -> %any} -> Array<String or Array<String>>', wrap: false
QDL.type :String, :scrub, '(?String) -> String'
QDL.type :String, :scrub, '(?String) {(%any) -> %any} -> String'
QDL.type :String, :scrub!, '(?String) -> String'
QDL.type :String, :scrub!, '(?String) {(%any) -> %any} -> String'
QDL.type :String, :setbyte, '(Integer, Integer) -> Integer'
QDL.type :String, :size, '() -> Integer'
QDL.type :String, :slice!, '(Integer, ?Integer) -> String or nil'
QDL.type :String, :slice!, '(Range<Integer> or Regexp) -> String or nil'
QDL.type :String, :slice!, '(Regexp, Integer) -> String or nil'
QDL.type :String, :slice!, '(Regexp, String) -> String or nil'
QDL.type :String, :slice!, '(String) -> String or nil'
QDL.type :String, :split, '(?(Regexp or String), ?Integer) -> Array<String>'
QDL.type :String, :split, '(?Integer) -> Array<String>'
QDL.type :String, :squeeze, '(?String) -> String'
QDL.type :String, :squeeze!, '(?String) -> String'
QDL.type :String, :start_with?, '(* String) -> %bool'
QDL.type :String, :strip, '() -> String'
QDL.type :String, :strip!, '() -> String'
QDL.type :String, :sub, '(Regexp or String, String or Hash) -> String', wrap: false # Can't wrap these, since they mess with $1 etc
QDL.type :String, :sub, '(Regexp or String) {(String) -> %any} -> String', wrap: false
QDL.type :String, :sub!, '(Regexp or String, String) -> String', wrap: false # TODO: Does this really not allow Hash?
QDL.type :String, :sub!, '(Regexp or String) {(String) -> %any} -> String', wrap: false
QDL.type :String, :succ, '() -> String'
QDL.type :String, :sum, '(?Integer) -> Integer'
QDL.type :String, :swapcase, '() -> String'
QDL.type :String, :swapcase!, '() -> String or nil'
QDL.type :String, :to_c, '() -> Complex'
QDL.type :String, :to_f, '() -> Float'
QDL.type :String, :to_i, '(?Integer) -> Integer'
QDL.type :String, :to_r, '() -> Rational'
QDL.type :String, :to_s, '() -> String'
QDL.type :String, :to_str, '() -> self'
QDL.type :String, :to_sym, '() -> Symbol'
QDL.type :String, :tr, '(String, String) -> String'
QDL.type :String, :tr!, '(String, String) -> String or nil'
QDL.type :String, :tr_s, '(String, String) -> String'
QDL.type :String, :tr_s!, '(String, String) -> String or nil'
QDL.type :String, :unpack, '(String) -> Array<String>'
QDL.type :String, :upcase, '() -> String'
QDL.type :String, :upcase!, '() -> String or nil'
QDL.type :String, :upto, '(String, ?bool) -> Enumerator'
QDL.type :String, :upto, '(String, ?bool) {(String) -> %any } -> String'
QDL.type :String, :valid_encoding?, '() -> %bool'

