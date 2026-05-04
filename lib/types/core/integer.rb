QDL.nowrap :Integer

def Numeric.sing_or_type(trec, targs, meth, type)
  if trec.is_a?(QDL::Type::SingletonType) && (targs.empty? || targs[0].is_a?(QDL::Type::SingletonType))
    #puts "We have reached the constant folding case for method #{meth}, receiver type #{trec}, and argument types #{targs}."
    if targs[0]
      v = QDL.type_cast(QDL.type_cast(trec, "QDL::Type::SingletonType<Integer>").val.send(meth, QDL.type_cast(targs[0], "QDL::Type::SingletonType").val), "Integer", force: true)
    else
      v = QDL.type_cast(QDL.type_cast(trec, "QDL::Type::SingletonType<Integer>").val.send(meth), "Integer", force: true)
    end
    QDL::Type::SingletonType.new(v.__getobj__)
  else
    QDL::Globals.parser.scan_str "#T #{type}"
  end
end
QDL.type Numeric, 'self.sing_or_type', "(QDL::Type::Type, Array<QDL::Type::Type>, Symbol, String) -> QDL::Type::Type", typecheck: :type_code, wrap: false


QDL.type :Integer, :%, '(Integer x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :%, "Integer")``'
QDL.type :Integer, :%, '(Float x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :%, "Float")``'
QDL.type :Integer, :%, '(Rational x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :%, "Rational")``'
QDL.type :Integer, :%, '(BigDecimal x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :%, "BigDecimal")``'

QDL.type :Integer, :&, '(Integer) -> ``sing_or_type(trec, targs, :&, "Integer")``'

QDL.type :Integer, :*, '(Integer) -> ``sing_or_type(trec, targs, :*, "Integer")``'
QDL.type :Integer, :*, '(Float) -> ``sing_or_type(trec, targs, :*, "Float")``'
QDL.type :Integer, :*, '(Rational) -> ``sing_or_type(trec, targs, :*, "Rational")``'
QDL.type :Integer, :*, '(BigDecimal) -> ``sing_or_type(trec, targs, :*, "BigDecimal")``'
QDL.type :Integer, :*, '(Complex) -> ``sing_or_type(trec, targs, :*, "Complex")``'
QDL.pre(:Integer, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

QDL.type :Integer, :**, '(Integer) -> ``sing_or_type(trec, targs, :**, "%numeric")``'
QDL.type :Integer, :**, '(Float) -> ``sing_or_type(trec, targs, :**, "%numeric")``'
QDL.type :Integer, :**, '(Rational) -> ``sing_or_type(trec, targs, :**, "%numeric")``'
QDL.type :Integer, :**, '(BigDecimal) -> ``sing_or_type(trec, targs, :**, "BigDecimal")``'
QDL.pre(:Integer, :**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
QDL.post(:Integer, :**) { |r,x| r.real?}
QDL.type :Integer, :**, '(Complex) -> ``sing_or_type(trec, targs, :**, "Complex")``'
QDL.pre(:Integer, :**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

QDL.type :Integer, :+, '(Integer) -> ``sing_or_type(trec, targs, :+, "Integer")``'
QDL.type :Integer, :+, '(Float) -> ``sing_or_type(trec, targs, :+, "Float")``'
QDL.type :Integer, :+, '(Rational) -> ``sing_or_type(trec, targs, :+, "Rational")``'
QDL.type :Integer, :+, '(BigDecimal) -> ``sing_or_type(trec, targs, :+, "BigDecimal")``'
QDL.type :Integer, :+, '(Complex) -> ``sing_or_type(trec, targs, :+, "Complex")``'

QDL.type :Integer, :-, '(Integer) -> ``sing_or_type(trec, targs, :-, "Integer")``'
QDL.type :Integer, :-, '(Float) -> ``sing_or_type(trec, targs, :-, "Float")``'
QDL.type :Integer, :-, '(Rational) -> ``sing_or_type(trec, targs, :-, "Rational")``'
QDL.type :Integer, :-, '(BigDecimal) -> ``sing_or_type(trec, targs, :-, "BigDecimal")``'
QDL.type :Integer, :-, '(Complex) -> ``sing_or_type(trec, targs, :-, "Complex")``'

QDL.type :Integer, :-@, '() -> ``sing_or_type(trec, targs, :-@, "Integer")``'

QDL.type :Integer, :+@, '() -> ``sing_or_type(trec, targs, :-@, "Integer")``'

QDL.type :Integer, :/, '(Integer x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :/, "Integer")``'
QDL.type :Integer, :/, '(Float x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :/, "Float")``'
QDL.type :Integer, :/, '(Rational x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :/, "Rational")``'
QDL.type :Integer, :/, '(BigDecimal x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :/, "BigDecimal")``'
QDL.type :Integer, :/, '(Complex x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :/, "Complex")``'
QDL.pre(:Integer, :/) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Integer, :<, '(Integer) -> ``sing_or_type(trec, targs, :<, "%bool")``'
QDL.type :Integer, :<, '(Float) -> ``sing_or_type(trec, targs, :<, "%bool")``'
QDL.type :Integer, :<, '(Rational) -> ``sing_or_type(trec, targs, :<, "%bool")``'
QDL.type :Integer, :<, '(BigDecimal) -> ``sing_or_type(trec, targs, :<, "%bool")``'

QDL.type :Integer, :<<, '(Integer) -> ``sing_or_type(trec, targs, :<<, "Integer")``'

QDL.type :Integer, :<=, '(Integer) -> ``sing_or_type(trec, targs, :<=, "%bool")``'
QDL.type :Integer, :<=, '(Float) -> ``sing_or_type(trec, targs, :<=, "%bool")``'
QDL.type :Integer, :<=, '(Rational) -> ``sing_or_type(trec, targs, :<=, "%bool")``'
QDL.type :Integer, :<=, '(BigDecimal) -> ``sing_or_type(trec, targs, :<=, "%bool")``'

QDL.type :Integer, :<=>, '(Integer) -> ``sing_or_type(trec, targs, :<=>, "Integer")``'
QDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
QDL.type :Integer, :<=>, '(Float) -> ``sing_or_type(trec, targs, :<=>, "Integer")``'
QDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
QDL.type :Integer, :<=>, '(Rational) -> ``sing_or_type(trec, targs, :<=>, "Integer")``'
QDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
QDL.type :Integer, :<=>, '(BigDecimal) -> ``sing_or_type(trec, targs, :<=>, "Integer")``'
QDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }

QDL.type :Integer, :==, '(Object) -> ``sing_or_type(trec, targs, :==, "%bool")``'

QDL.type :Integer, :!=, '(``targs[0]``) -> ``sing_or_type(trec, targs, :==, "%bool")``'

QDL.type :Integer, :===, '(Object) -> ``sing_or_type(trec, targs, :===, "%bool")``'

QDL.type :Integer, :>, '(Integer) -> ``sing_or_type(trec, targs, :>, "%bool")``'
QDL.type :Integer, :>, '(Float) -> ``sing_or_type(trec, targs, :>, "%bool")``'
QDL.type :Integer, :>, '(Rational) -> ``sing_or_type(trec, targs, :>, "%bool")``'
QDL.type :Integer, :>, '(BigDecimal) -> ``sing_or_type(trec, targs, :>, "%bool")``'

QDL.type :Integer, :>=, '(Integer) -> ``sing_or_type(trec, targs, :>=, "%bool")``'
QDL.type :Integer, :>=, '(Float) -> ``sing_or_type(trec, targs, :>=, "%bool")``'
QDL.type :Integer, :>=, '(Rational) -> ``sing_or_type(trec, targs, :>=, "%bool")``'
QDL.type :Integer, :>=, '(BigDecimal) -> ``sing_or_type(trec, targs, :>=, "%bool")``'

QDL.type :Integer, :>>, '(Integer) -> Integer r {{ r >= 0 }}' ## TODO

QDL.type :Integer, :[], '(Integer) -> ``sing_or_type(trec, targs, :[], "Integer")``'
QDL.post(:Integer, :[]) { |r,x| r == 0 || r==1}
QDL.type :Integer, :[], '(Rational) -> ``sing_or_type(trec, targs, :[], "Integer")``'
QDL.post(:Integer, :[]) { |r,x| r == 0 || r==1}
QDL.type :Integer, :[], '(Float) -> ``sing_or_type(trec, targs, :[], "Integer")``'
QDL.pre(:Integer, :[]) { |x| x != Float::INFINITY && !x.nan? }
QDL.post(:Integer, :[]) { |r,x| r == 0 || r==1}
QDL.type :Integer, :[], '(BigDecimal) -> ``sing_or_type(trec, targs, :[], "Integer")``'
QDL.pre(:Integer, :[]) { |x| x != BigDecimal::INFINITY && !x.nan? }
QDL.post(:Integer, :[]) { |r,x| r == 0 || r == 1 }

QDL.type :Integer, :^, '(Integer) -> ``sing_or_type(trec, targs, :^, "Integer")``'

QDL.type :Integer, :|, '(Integer) -> ``sing_or_type(trec, targs, :|, "Integer")``'

QDL.type :Integer, :~, '() -> ``sing_or_type(trec, targs, :~, "Integer")``'

QDL.type :Integer, :abs, '() -> Integer r {{ r>=0 }}' ## TODO

QDL.type :Integer, :bit_length, '() -> Integer r {{ r>=0 }}' ## TODO

QDL.type :Integer, :div, '(Integer x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :div, "Integer")``'
QDL.type :Integer, :div, '(Float x {{ x!=0 && !x.nan? }}) -> ``sing_or_type(trec, targs, :div, "Integer")``'
QDL.type :Integer, :div, '(Rational x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :div, "Integer")``'
QDL.type :Integer, :div, '(BigDecimal x {{ x!=0 && !x.nan? }}) -> ``sing_or_type(trec, targs, :div, "Integer")``'

QDL.type :Integer, :divmod, '(%real x {{ x!=0 }}) -> [%real, %real]'
QDL.pre(:Integer, :divmod) { |x| if x.is_a?(Float) then !x.nan? else true end}

QDL.type :Integer, :fdiv, '(Integer) -> ``sing_or_type(trec, targs, :fdiv, "Float")``'
QDL.type :Integer, :fdiv, '(Float) -> ``sing_or_type(trec, targs, :fdiv, "Float")``'
QDL.type :Integer, :fdiv, '(Rational) -> ``sing_or_type(trec, targs, :fdiv, "Float")``'
QDL.type :Integer, :fdiv, '(BigDecimal) -> ``sing_or_type(trec, targs, :fdiv, "BigDecimal")``'
QDL.type :Integer, :fdiv, '(Complex) -> ``sing_or_type(trec, targs, :fdiv, "Complex")``'
QDL.pre(:Integer, :fdiv) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Integer, :to_s, '(?Integer) -> String'
QDL.type :Integer, :inspect, '() -> String'

QDL.type :Integer, :magnitude, '() -> Integer r {{ r>=0 }}' ## TODO

QDL.type :Integer, :modulo, '(Integer x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :modulo, "Integer")``'
QDL.type :Integer, :modulo, '(Float x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :modulo, "Float")``'
QDL.type :Integer, :modulo, '(Rational x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :modulo, "Rational")``'
QDL.type :Integer, :modulo, '(BigDecimal x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :modulo, "BigDecimal")``'

QDL.type :Integer, :quo, '(Integer x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :quo, "Integer")``'
QDL.type :Integer, :quo, '(Float x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :quo, "Float")``'
QDL.type :Integer, :quo, '(Rational x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :quo, "Rational")``'
QDL.type :Integer, :quo, '(BigDecimal x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :quo, "BigDecimal")``'
QDL.type :Integer, :quo, '(Complex x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :quo, "Complex")``'
QDL.pre(:Integer, :quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Integer, :abs2, '() -> Integer r {{ r>=0 }}' ## TODO
QDL.type :Integer, :angle, '() -> ``sing_or_type(trec, targs, :angle, "%numeric")``'
QDL.post(:Integer, :angle) { |r,x| r == 0 || r == Math::PI}
QDL.type :Integer, :arg, '() -> ``sing_or_type(trec, targs, :arg, "%numeric")``'
QDL.post(:Integer, :arg) { |r,x| r == 0 || r == Math::PI}
QDL.type :Integer, :equal?, '(Object) -> ``sing_or_type(trec, targs, :equal?, "%bool")``'
QDL.type :Integer, :eql?, '(Object) -> ``sing_or_type(trec, targs, :eql?, "%bool")``'
QDL.type :Integer, :hash, '() -> Integer'
QDL.type :Integer, :ceil, '() -> ``sing_or_type(trec, targs, :ceil, "Integer")``'
QDL.type :Integer, :chr, '(?Encoding) -> String'
QDL.type :Integer, :coerce, '(%numeric) -> [%real, %real]'
QDL.pre(:Integer, :coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
QDL.type :Integer, :conj, '() -> ``sing_or_type(trec, targs, :conj, "Integer")``'
QDL.type :Integer, :conjugate, '() -> ``sing_or_type(trec, targs, :conjugate, "Integer")``'
QDL.type :Integer, :denominator, '() -> ``sing_or_type(trec, targs, :denominator, "Integer")``'
QDL.post(:Integer, :denominator) { |r,x| r == 1 }
QDL.type :Integer, :downto, '(Integer) { (Integer) -> %any } -> Integer'
QDL.type :Integer, :downto, '(Integer limit) -> Enumerator<Integer>'
QDL.type :Integer, :even?, '() -> ``sing_or_type(trec, targs, :even?, "%bool")``'
QDL.type :Integer, :gcd, '(Integer) -> ``sing_or_type(trec, targs, :gcd, "Integer")``'
QDL.type :Integer, :gcdlcm, '(Integer) -> [Integer, Integer]'
QDL.type :Integer, :floor, '() -> ``sing_or_type(trec, targs, :floor, "Integer")``'
QDL.type :Integer, :imag, '() -> Integer r {{ r==0 }}' ## TODO
QDL.type :Integer, :imaginary, '() -> Integer r {{ r==0 }}' ## TODO
QDL.type :Integer, :integer?, '() -> true'
QDL.type :Integer, :lcm, '(Integer) -> ``sing_or_type(trec, targs, :lcm, "Integer")``'
QDL.type :Integer, :next, '() -> ``sing_or_type(trec, targs, :next, "Integer")``'
QDL.type :Integer, :numerator, '() -> ``sing_or_type(trec, targs, :numerator, "Integer")``'
QDL.type :Integer, :odd?, '() -> ``sing_or_type(trec, targs, :odd?, "%bool")``'
QDL.type :Integer, :ord, '() -> ``sing_or_type(trec, targs, :ord, "Integer")``'
QDL.type :Integer, :phase, '() -> ``sing_or_type(trec, targs, :phase, "%numeric")``'
QDL.type :Integer, :pred, '() -> ``sing_or_type(trec, targs, :pred, "Integer")``'
QDL.type :Integer, :rationalize, '() -> Rational' ## TODO
QDL.type :Integer, :rationalize, '(%numeric) -> Rational' ## TODO
QDL.type :Integer, :real, '() -> ``sing_or_type(trec, targs, :real, "Integer")``'
QDL.type :Integer, :real?, '() -> true'
QDL.type :Integer, :remainder, '(Integer x {{ x!=0 }}) -> Integer r {{ r>=0 }}' ## TODO
QDL.type :Integer, :remainder, '(Float x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :remainder, "Float")``'
QDL.type :Integer, :remainder, '(Rational x {{ x!=0 }}) -> Rational r {{ r>=0 }}' ## TODO
QDL.type :Integer, :remainder, '(BigDecimal x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :gcd, "BigDecimal")``'
QDL.type :Integer, :round, '() -> ``sing_or_type(trec, targs, :round, "Integer")``'
QDL.type :Integer, :round, '(%numeric, ?%numeric) -> ``sing_or_type(trec, targs, :round, "%numeric")``'
QDL.pre(:Integer, :round) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].
QDL.type :Integer, :size, '() -> ``sing_or_type(trec, targs, :size, "Integer")``'
QDL.type :Integer, :succ, '() -> ``sing_or_type(trec, targs, :succ, "Integer")``'
QDL.type :Integer, :times, '() { (Integer) -> %any } -> Integer'
QDL.type :Integer, :times, '() { () -> %any } -> Integer'
QDL.type :Integer, :times, '() -> Enumerator<Integer>'
QDL.type :Integer, :to_c, '() -> Complex r {{ r.imaginary==0 }}'
QDL.type :Integer, :to_d, '(?Integer) -> BigDecimal'
QDL.type :Integer, :to_f, '() -> ``sing_or_type(trec, targs, :to_f, "Float")``'
QDL.type :Integer, :to_i, '() -> self'
QDL.type :Integer, :to_int, '() -> self'
QDL.type :Integer, :to_r, '() -> Rational' ## TODO
QDL.type :Integer, :truncate, '() -> ``sing_or_type(trec, targs, :truncate, "Integer")``'
QDL.type :Integer, :upto, '(Integer) { (Integer) -> %any } -> Integer'
QDL.type :Integer, :upto, '(Integer) -> Enumerator<Integer>'
QDL.type :Integer, :zero?, '() -> ``sing_or_type(trec, targs, :zero?, "%bool")``'


######### Non-dependent types below #########


QDL.type :Integer, :%, '(Integer x {{ x!=0 }}) -> Integer'
QDL.type :Integer, :%, '(Float x {{ x!=0 }}) -> Float'
QDL.type :Integer, :%, '(Rational x {{ x!=0 }}) -> Rational'
QDL.type :Integer, :%, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'

QDL.type :Integer, :&, '(Integer) -> Integer'

QDL.type :Integer, :*, '(Integer) -> Integer'
QDL.type :Integer, :*, '(Float) -> Float'
QDL.type :Integer, :*, '(Rational) -> Rational'
QDL.type :Integer, :*, '(BigDecimal) -> BigDecimal'
QDL.type :Integer, :*, '(Complex) -> Complex'
QDL.pre(:Integer, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

QDL.type :Integer, :**, '(Integer) -> %numeric'
QDL.type :Integer, :**, '(Float) -> %numeric'
QDL.type :Integer, :**, '(Rational) -> %numeric'
QDL.type :Integer, :**, '(BigDecimal) -> BigDecimal'
QDL.pre(:Integer, :**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
QDL.post(:Integer, :**) { |r,x| r.real?}
QDL.type :Integer, :**, '(Complex) -> Complex'
QDL.pre(:Integer, :**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

QDL.type :Integer, :+, '(Integer) -> Integer'
QDL.type :Integer, :+, '(Float) -> Float'
QDL.type :Integer, :+, '(Rational) -> Rational'
QDL.type :Integer, :+, '(BigDecimal) -> BigDecimal'
QDL.type :Integer, :+, '(Complex) -> Complex'

QDL.type :Integer, :-, '(Integer) -> Integer'
QDL.type :Integer, :-, '(Float) -> Float'
QDL.type :Integer, :-, '(Rational) -> Rational'
QDL.type :Integer, :-, '(BigDecimal) -> BigDecimal'
QDL.type :Integer, :-, '(Complex) -> Complex'

QDL.type :Integer, :-@, '() -> Integer'

QDL.type :Integer, :+@, '() -> Integer'

QDL.type :Integer, :/, '(Integer x {{ x!=0 }}) -> Integer'
QDL.type :Integer, :/, '(Float x {{ x!=0 }}) -> Float'
QDL.type :Integer, :/, '(Rational x {{ x!=0 }}) -> Rational'
QDL.type :Integer, :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
QDL.type :Integer, :/, '(Complex x {{ x!=0 }}) -> Complex'
QDL.pre(:Integer, :/) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Integer, :<, '(Integer) -> %bool'
QDL.type :Integer, :<, '(Float) -> %bool'
QDL.type :Integer, :<, '(Rational) -> %bool'
QDL.type :Integer, :<, '(BigDecimal) -> %bool'

QDL.type :Integer, :<<, '(Integer) -> Integer'

QDL.type :Integer, :<=, '(Integer) -> %bool'
QDL.type :Integer, :<=, '(Float) -> %bool'
QDL.type :Integer, :<=, '(Rational) -> %bool'
QDL.type :Integer, :<=, '(BigDecimal) -> %bool'

QDL.type :Integer, :<=>, '(Integer) -> Object'
QDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
QDL.type :Integer, :<=>, '(Float) -> Object'
QDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
QDL.type :Integer, :<=>, '(Rational) -> Object'
QDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
QDL.type :Integer, :<=>, '(BigDecimal) -> Object'
QDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }

QDL.type :Integer, :==, '(Object) -> %bool'

QDL.type :Integer, :===, '(Object) -> %bool'

QDL.type :Integer, :>, '(Integer) -> %bool'
QDL.type :Integer, :>, '(Float) -> %bool'
QDL.type :Integer, :>, '(Rational) -> %bool'
QDL.type :Integer, :>, '(BigDecimal) -> %bool'

QDL.type :Integer, :>=, '(Integer) -> %bool'
QDL.type :Integer, :>=, '(Float) -> %bool'
QDL.type :Integer, :>=, '(Rational) -> %bool'
QDL.type :Integer, :>=, '(BigDecimal) -> %bool'

QDL.type :Integer, :>>, '(Integer) -> Integer r {{ r >= 0 }}'

QDL.type :Integer, :[], '(Integer) -> Integer'
QDL.post(:Integer, :[]) { |r,x| r == 0 || r==1}
QDL.type :Integer, :[], '(Rational) -> Integer'
QDL.post(:Integer, :[]) { |r,x| r == 0 || r==1}
QDL.type :Integer, :[], '(Float) -> Integer'
QDL.pre(:Integer, :[]) { |x| x != Float::INFINITY && !x.nan? }
QDL.post(:Integer, :[]) { |r,x| r == 0 || r==1}
QDL.type :Integer, :[], '(BigDecimal) -> Integer'
QDL.pre(:Integer, :[]) { |x| x != BigDecimal::INFINITY && !x.nan? }
QDL.post(:Integer, :[]) { |r,x| r == 0 || r == 1 }

QDL.type :Integer, :^, '(Integer) -> Integer'

QDL.type :Integer, :|, '(Integer) -> Integer'

QDL.type :Integer, :~, '() -> Integer'

QDL.type :Integer, :abs, '() -> Integer r {{ r>=0 }}'

QDL.type :Integer, :bit_length, '() -> Integer r {{ r>=0 }}'

QDL.type :Integer, :div, '(Integer x {{ x!=0 }}) -> Integer'
QDL.type :Integer, :div, '(Float x {{ x!=0 && !x.nan? }}) -> Integer'
QDL.type :Integer, :div, '(Rational x {{ x!=0 }}) -> Integer'
QDL.type :Integer, :div, '(BigDecimal x {{ x!=0 && !x.nan? }}) -> Integer'

QDL.type :Integer, :divmod, '(%real x {{ x!=0 }}) -> [%real, %real]'
QDL.pre(:Integer, :divmod) { |x| if x.is_a?(Float) then !x.nan? else true end}

QDL.type :Integer, :fdiv, '(Integer) -> Float'
QDL.type :Integer, :fdiv, '(Float) -> Float'
QDL.type :Integer, :fdiv, '(Rational) -> Float'
QDL.type :Integer, :fdiv, '(BigDecimal) -> BigDecimal'
QDL.type :Integer, :fdiv, '(Complex) -> Complex'
QDL.pre(:Integer, :fdiv) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Integer, :to_s, '(?Integer) -> String'
QDL.type :Integer, :inspect, '() -> String'

QDL.type :Integer, :magnitude, '() -> Integer r {{ r>=0 }}'

QDL.type :Integer, :modulo, '(Integer x {{ x!=0 }}) -> Integer'
QDL.type :Integer, :modulo, '(Float x {{ x!=0 }}) -> Float'
QDL.type :Integer, :modulo, '(Rational x {{ x!=0 }}) -> Rational'
QDL.type :Integer, :modulo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'

QDL.type :Integer, :quo, '(Integer x {{ x!=0 }}) -> Rational'
QDL.type :Integer, :quo, '(Float x {{ x!=0 }}) -> Float'
QDL.type :Integer, :quo, '(Rational x {{ x!=0 }}) -> Rational'
QDL.type :Integer, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
QDL.type :Integer, :quo, '(Complex x {{ x!=0 }}) -> Complex'
QDL.pre(:Integer, :quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Integer, :abs2, '() -> Integer r {{ r>=0 }}'
QDL.type :Integer, :angle, '() -> %numeric'
QDL.post(:Integer, :angle) { |r,x| r == 0 || r == Math::PI}
QDL.type :Integer, :arg, '() -> %numeric'
QDL.post(:Integer, :arg) { |r,x| r == 0 || r == Math::PI}
QDL.type :Integer, :equal?, '(Object) -> %bool'
QDL.type :Integer, :eql?, '(Object) -> %bool'
QDL.type :Integer, :hash, '() -> Integer'
QDL.type :Integer, :ceil, '() -> Integer'
QDL.type :Integer, :chr, '(?Encoding) -> String'
QDL.type :Integer, :coerce, '(%numeric) -> [%real, %real]'
QDL.pre(:Integer, :coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
QDL.type :Integer, :conj, '() -> Integer'
QDL.type :Integer, :conjugate, '() -> Integer'
QDL.type :Integer, :denominator, '() -> Integer'
QDL.post(:Integer, :denominator) { |r,x| r == 1 }
QDL.type :Integer, :downto, '(Integer) { (Integer) -> %any } -> Integer'
QDL.type :Integer, :downto, '(Integer limit) -> Enumerator<Integer>'
QDL.type :Integer, :even?, '() -> %bool'
QDL.type :Integer, :gcd, '(Integer) -> Integer'
QDL.type :Integer, :gcdlcm, '(Integer) -> [Integer, Integer]'
QDL.type :Integer, :floor, '() -> Integer'
QDL.type :Integer, :imag, '() -> Integer r {{ r==0 }}'
QDL.type :Integer, :imaginary, '() -> Integer r {{ r==0 }}'
QDL.type :Integer, :integer?, '() -> true'
QDL.type :Integer, :lcm, '(Integer) -> Integer'
QDL.type :Integer, :next, '() -> Integer'
QDL.type :Integer, :numerator, '() -> Integer'
QDL.type :Integer, :odd?, '() -> %bool'
QDL.type :Integer, :ord, '() -> Integer'
QDL.type :Integer, :phase, '() -> %numeric'
QDL.type :Integer, :pred, '() -> Integer'
QDL.type :Integer, :rationalize, '() -> Rational'
QDL.type :Integer, :rationalize, '(%numeric) -> Rational'
QDL.type :Integer, :real, '() -> Integer'
QDL.type :Integer, :real?, '() -> true'
QDL.type :Integer, :remainder, '(Integer x {{ x!=0 }}) -> Integer r {{ r>=0 }}'
QDL.type :Integer, :remainder, '(Float x {{ x!=0 }}) -> Float'
QDL.type :Integer, :remainder, '(Rational x {{ x!=0 }}) -> Rational r {{ r>=0 }}'
QDL.type :Integer, :remainder, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
QDL.type :Integer, :round, '() -> Integer'
QDL.type :Integer, :round, '(%numeric) -> %numeric'
QDL.pre(:Integer, :round) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].
QDL.type :Integer, :size, '() -> Integer'
QDL.type :Integer, :succ, '() -> Integer'
QDL.type :Integer, :times, '() { (Integer) -> %any } -> Integer'
QDL.type :Integer, :times, '() { () -> %any } -> Integer'
QDL.type :Integer, :times, '() -> Enumerator<Integer>'
QDL.type :Integer, :to_c, '() -> Complex r {{ r.imaginary==0 }}'
QDL.type :Integer, :to_f, '() -> Float'
QDL.type :Integer, :to_i, '() -> Integer'
QDL.type :Integer, :to_int, '() -> Integer'
QDL.type :Integer, :to_r, '() -> Rational'
QDL.type :Integer, :truncate, '() -> Integer'
QDL.type :Integer, :upto, '(Integer) { (?Integer) -> %any } -> Integer'
QDL.type :Integer, :upto, '(Integer) -> Enumerator<Integer>'
QDL.type :Integer, :zero?, '() -> %bool'
