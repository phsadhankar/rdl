QDL.nowrap :Fixnum

QDL.type :Fixnum, :%, '(Fixnum x {{ x!=0 }}) -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :%, '(Bignum x {{ x!=0 }}) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :%, '(Float x {{ x!=0 }}) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :%, '(Rational x {{ x!=0}}) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :%, '(BigDecimal x {{ x!=0}}) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :&, '(Integer) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :*, '(Integer) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :*, '(Float) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :*, '(Rational) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :*, '(BigDecimal) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :*, '(Complex) -> Complex', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Fixnum, :*, version: QDL::Globals::FIXBIG_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

QDL.type :Fixnum, :**, '(Integer) -> %numeric', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :**, '(Float) -> %numeric', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :**, '(Rational) -> %numeric', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :**, '(BigDecimal) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Fixnum, :**, version: QDL::Globals::FIXBIG_VERSIONS) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
QDL.post(:Fixnum, :**, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r.real?}
QDL.type :Fixnum, :**, '(Complex) -> Complex', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Fixnum, :**, version: QDL::Globals::FIXBIG_VERSIONS) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

QDL.type :Fixnum, :+, '(Integer) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :+, '(Float) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :+, '(Rational) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :+, '(BigDecimal) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :+, '(Complex) -> Complex', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :-, '(Integer) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :-, '(Float) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :-, '(Rational) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :-, '(BigDecimal) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :-, '(Complex) -> Complex', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :-@, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :+@, '() -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :/, '(Integer x {{ x!=0 }}) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :/, '(Float x {{ x!=0 }}) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :/, '(Rational x {{ x!=0 }}) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :/, '(Complex x {{ x!=0 }}) -> Complex', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Fixnum, :/, version: QDL::Globals::FIXBIG_VERSIONS) { if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Fixnum, :<, '(Integer) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :<, '(Float) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :<, '(Rational) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :<, '(BigDecimal) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :<<, '(Fixnum) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :<=, '(Integer) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :<=, '(Float) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :<=, '(Rational) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :<=, '(BigDecimal) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :<=>, '(Integer) -> Object', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Fixnum, :<=>, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
QDL.type :Fixnum, :<=>, '(Float) -> Object', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Fixnum, :<=>, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
QDL.type :Fixnum, :<=>, '(Rational) -> Object', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Fixnum, :<=>, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
QDL.type :Fixnum, :<=>, '(BigDecimal) -> Object', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Fixnum, :<=>, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}

QDL.type :Fixnum, :==, '(Object) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :===, '(Object) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :>, '(Integer) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :>, '(Float) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :>, '(Rational) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :>, '(BigDecimal) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :>=, '(Integer) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :>=, '(Float) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :>=, '(Rational) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :>=, '(BigDecimal) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :>>, '(Integer) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Fixnum, :>>, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r >= 0 }

QDL.type :Fixnum, :[], '(Integer) -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Fixnum, :[], version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}
QDL.type :Fixnum, :[], '(Rational) -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Fixnum, :[], version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}
QDL.type :Fixnum, :[], '(Float) -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Fixnum, :[], version: QDL::Globals::FIXBIG_VERSIONS) { |x| x!=Float::INFINITY && !x.nan? }
QDL.post(:Fixnum, :[], version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}
QDL.type :Fixnum, :[], '(BigDecimal) -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Fixnum, :[], version: QDL::Globals::FIXBIG_VERSIONS) { |x| x!=BigDecimal::INFINITY && !x.nan? }
QDL.post(:Fixnum, :[], version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}

QDL.type :Fixnum, :^, '(Integer) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :|, '(Integer) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :~, '() -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :abs, '() -> Integer r {{ r>=0 }}', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :bit_length, '() -> Fixnum r {{ r>=0 }}', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :div, '(Fixnum x {{ x!=0 }}) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :div, '(Bignum x {{ x!=0 }}) -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :div, '(Float x {{ x!=0 && !x.nan? }}) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :div, '(Rational x {{ x!=0 }}) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :div, '(BigDecimal x {{ x!=0 && !x.nan? }}) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :divmod, '(%real x {{ x!=0 }}) -> [%real, %real]', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Fixnum, :divmod, version: QDL::Globals::FIXBIG_VERSIONS) { |x| if x.is_a?(Float) then !x.nan? else true end}

QDL.type :Fixnum, :even?, '() -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :fdiv, '(Integer) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :fdiv, '(Float) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :fdiv, '(Rational) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :fdiv, '(BigDecimal) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :fdiv, '(Complex) -> Complex', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Fixnum, :fdiv, version: QDL::Globals::FIXBIG_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Fixnum, :to_s, '() -> String', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :inspect, '() -> String', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :magnitude, '() -> Integer r {{ r>=0 }}', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :modulo, '(Fixnum x {{ x!=0 }}) -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :modulo, '(Bignum x {{ x!=0 }}) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :modulo, '(Float x {{ x!=0 }}) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :modulo, '(Rational x {{ x!=0 }}) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :modulo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :next, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :odd?, '() -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :size, '() -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :succ, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :to_f, '() -> Float', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :zero?, '() -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :ceil, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :denominator, '() -> Fixnum r {{ r==1 }}', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :floor, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :numerator, '() -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :quo, '(Integer x {{ x!=0 }}) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :quo, '(Float x {{ x!=0 }}) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :quo, '(Rational x {{ x!=0 }}) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :quo, '(Complex x {{ x!=0 }}) -> Complex', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Fixnum, :quo, version: QDL::Globals::FIXBIG_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Fixnum, :rationalize, '() -> Rational', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :rationalize, '(%numeric) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :round, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :round, '(%numeric) -> %numeric', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Fixnum, :round, version: QDL::Globals::FIXBIG_VERSIONS) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

QDL.type :Fixnum, :to_i, '() -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :to_r, '() -> Rational', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :truncate, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :angle, '() -> %numeric', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Fixnum, :angle, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r == Math::PI}

QDL.type :Fixnum, :arg, '() -> %numeric', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Fixnum, :arg, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r == Math::PI}

QDL.type :Fixnum, :equal?, '(Object) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :eql?, '(Object) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :hash, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :phase, '() -> %numeric', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :abs2, '() -> Integer r {{ r>=0 }}', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :conj, '() -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :conjugate, '() -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :imag, '() -> Fixnum r {{ r==0 }}', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :imaginary, '() -> Fixnum r {{ r==0 }}', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :real, '() -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :real?, '() -> true', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :to_c, '() -> Complex r {{ r.imaginary == 0 }}', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :remainder, '(Fixnum x {{ x!=0 }}) -> Fixnum r {{ r>0 }}', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :remainder, '(Bignum x {{ x!=0 }}) -> Fixnum r {{ r>0 }}', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :remainder, '(Float x {{ x!=0 }}) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :remainder, '(Rational x {{ x!=0 }}) -> Rational r {{ r>0 }}', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Fixnum, :remainder, '(BigDecimal x {{ x=0 }}) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Fixnum, :coerce, '(%numeric) -> [%real, %real]', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Fixnum, :coerce, version: QDL::Globals::FIXBIG_VERSIONS) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
