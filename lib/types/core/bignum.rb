QDL.nowrap :Bignum

QDL.type :Bignum, :%, '(Fixnum x {{ x!=0 }}) -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :%, '(Bignum x {{ x!=0 }}) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :%, '(Float x {{ x!=0 }}) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :%, '(Rational x {{ x!=0 }}) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :%, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :&, '(Integer) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :*, '(Fixnum) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :*, '(Bignum) -> Bignum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :*, '(Float) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :*, '(Rational) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :*, '(BigDecimal) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :*, '(Complex) -> Complex', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Bignum, :*, version: QDL::Globals::FIXBIG_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

QDL.type :Bignum, :**, '(Integer) -> %numeric', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :**, '(Float) -> %numeric', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :**, '(Rational) -> %numeric', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :**, '(BigDecimal) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Bignum, :**, version: QDL::Globals::FIXBIG_VERSIONS) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
QDL.post(:Bignum, :**, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r.real?}
QDL.type :Bignum, :**, '(Complex) -> Complex', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Bignum, :**, version: QDL::Globals::FIXBIG_VERSIONS) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

QDL.type :Bignum, :+, '(Integer) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :+, '(Float) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :+, '(Rational) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :+, '(BigDecimal) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :+, '(Complex) -> Complex', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :-, '(Integer) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :-, '(Float) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :-, '(Rational) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :-, '(BigDecimal) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :-, '(Complex) -> Complex', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :-@, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :+@, '() -> Bignum', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :/, '(Integer x {{ x!=0 }}) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :/, '(Float x {{ x!=0 }}) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :/, '(Rational x {{ x!=0 }}) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :/, '(Complex x {{ x!=0 }}) -> Complex', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Bignum, :/, version: QDL::Globals::FIXBIG_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Bignum, :<, '(Integer) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :<, '(Float) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :<, '(Rational) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :<, '(BigDecimal) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :<<, '(Fixnum) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :<=, '(Integer) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :<=, '(Float) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :<=, '(Rational) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :<=, '(BigDecimal) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :<=>, '(Integer) -> Object', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Bignum, :<=>, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
QDL.type :Bignum, :<=>, '(Float) -> Object', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Bignum, :<=>, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
QDL.type :Bignum, :<=>, '(Rational) -> Object', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Bignum, :<=>, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
QDL.type :Bignum, :<=>, '(BigDecimal) -> Object', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Bignum, :<=>, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}

QDL.type :Bignum, :==, '(Object) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :===, '(Object) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :>, '(Integer) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :>, '(Float) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :>, '(Rational) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :>, '(BigDecimal) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :>=, '(Integer) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :>=, '(Float) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :>=, '(Rational) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :>=, '(BigDecimal) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :>>, '(Integer) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Bignum, :>>, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r >= 0 }

QDL.type :Bignum, :[], '(Integer) -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Bignum, :[], version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}
QDL.type :Bignum, :[], '(Rational) -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Bignum, :[], version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}
QDL.type :Bignum, :[], '(Float) -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Bignum, :[], version: QDL::Globals::FIXBIG_VERSIONS) { |x| x!=Float::INFINITY && !x.nan? }
QDL.post(:Bignum, :[], version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}
QDL.type :Bignum, :[], '(BigDecimal) -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Bignum, :[], version: QDL::Globals::FIXBIG_VERSIONS) { |x| x!=BigDecimal::INFINITY && !x.nan? }
QDL.post(:Bignum, :[], version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}

QDL.type :Bignum, :^, '(Integer) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :|, '(Integer) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :~, '() -> Bignum', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :abs, '() -> Bignum r {{ r>=0 }}', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :bit_length, '() -> Integer r {{ r>=0 }}', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :div, '(Integer x {{ x!=0 }}) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :div, '(Float x {{ x!=0 && !x.nan? }}) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :div, '(Rational x {{ x!=0 }}) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :div, '(BigDecimal x {{ x!=0 && !x.nan?}}) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :divmod, '(%real) -> [%real, %real]', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Bignum, :divmod, version: QDL::Globals::FIXBIG_VERSIONS) { |x| x!=0 && if x.is_a?(Float) then !x.nan? else true end}

QDL.type :Bignum, :even?, '() -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :fdiv, '(Integer) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :fdiv, '(Float) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :fdiv, '(Rational) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :fdiv, '(BigDecimal) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :fdiv, '(Complex) -> Complex', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Bignum, :fdiv, version: QDL::Globals::FIXBIG_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Bignum, :to_s, '() -> String', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :inspect, '() -> String', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :magnitude, '() -> Bignum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Bignum, :magnitude, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r >= 0 }

QDL.type :Bignum, :modulo, '(Fixnum x {{ x!=0 }}) -> Fixnum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :modulo, '(Bignum x {{ x!=0 }}) -> Integer', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :modulo, '(Float x {{ x!=0 }}) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :modulo, '(Rational x {{ x!=0 }}) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :modulo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :next, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :odd?, '() -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :size, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :succ, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :to_f, '() -> Float', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :zero?, '() -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :ceil, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :denominator, '() -> Fixnum r {{ r==1 }}', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :floor, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :numerator, '() -> Bignum', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :quo, '(Integer x {{ x!=0 }}) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :quo, '(Float x {{ x!=0 }}) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :quo, '(Rational x {{ x!=0 }}) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :quo, '(Complex x {{ x!=0 }}) -> Complex', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Bignum, :quo, version: QDL::Globals::FIXBIG_VERSIONS) { if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Bignum, :rationalize, '() -> Rational', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :rationalize, '(%numeric) -> Rational', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :round, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :round, '(%numeric) -> %numeric', version: QDL::Globals::FIXBIG_VERSIONS
QDL.pre(:Bignum, :round, version: QDL::Globals::FIXBIG_VERSIONS) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

QDL.type :Bignum, :to_i, '() -> Bignum', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :to_r, '() -> Rational', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :truncate, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :angle, '() -> %numeric', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Bignum, :angle, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r == Math::PI}

QDL.type :Bignum, :arg, '() -> %numeric', version: QDL::Globals::FIXBIG_VERSIONS
QDL.post(:Bignum, :arg, version: QDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r == Math::PI}

QDL.type :Bignum, :equal?, '(Object) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :eql?, '(Object) -> %bool', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :hash, '() -> Integer', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :phase, '() -> %numeric', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :abs2, '() -> Bignum r {{ r>=0 }}', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :conj, '() -> Bignum', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :conjugate, '() -> Bignum', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :imag, '() -> Fixnum r {{ r==0 }}', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :imaginary, '() -> Fixnum r {{ r==0 }}', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :real, '() -> Bignum', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :real?, '() -> true', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :to_c, '() -> Complex r {{ r.imaginary==0 }}', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :remainder, '(Fixnum x {{ x!=0 }}) -> Fixnum r {{ r>=0 }}', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :remainder, '(Bignum x {{ x!=0 }}) -> Fixnum r {{ r>=0 }}', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :remainder, '(Float x {{ x!=0 }}) -> Float', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :remainder, '(Rational x {{ x!=0 }}) -> Rational r {{ r>=0 }}', version: QDL::Globals::FIXBIG_VERSIONS
QDL.type :Bignum, :remainder, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: QDL::Globals::FIXBIG_VERSIONS

QDL.type :Bignum, :coerce, '(Integer) -> [Integer, Integer]', version: QDL::Globals::FIXBIG_VERSIONS
