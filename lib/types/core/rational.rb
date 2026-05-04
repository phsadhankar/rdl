QDL.nowrap :Rational

QDL.type :Rational, :%, '(Integer) -> Rational'
QDL.pre(:Rational, :%) { |x| x!=0}
QDL.type :Rational, :%, '(Float) -> Float'
QDL.pre(:Rational, :%) { |x| x!=0&&!x.nan?}
QDL.type :Rational, :%, '(Rational) -> Rational'
QDL.pre(:Rational, :%) { |x| x!=0}
QDL.type :Rational, :%, '(BigDecimal) -> BigDecimal'
QDL.pre(:Rational, :%) { |x| x!=0&&!x.nan?}

QDL.type :Rational, :*, '(Integer) -> Rational'
QDL.type :Rational, :*, '(Float) -> Float'
QDL.type :Rational, :*, '(Rational) -> Rational'
QDL.type :Rational, :*, '(BigDecimal) -> BigDecimal'
QDL.type :Rational, :*, '(Complex) -> Complex'
QDL.pre(:Rational, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

QDL.type :Rational, :+, '(Integer) -> Rational'
QDL.type :Rational, :+, '(Float) -> Float'
QDL.type :Rational, :+, '(Rational) -> Rational'
QDL.type :Rational, :+, '(BigDecimal) -> BigDecimal'
QDL.type :Rational, :+, '(Complex) -> Complex'

QDL.type :Rational, :-, '(Integer) -> Rational'
QDL.type :Rational, :-, '(Float) -> Float'
QDL.type :Rational, :-, '(Rational) -> Rational'
QDL.type :Rational, :-, '(BigDecimal) -> BigDecimal'
QDL.type :Rational, :-, '(Complex) -> Complex'

QDL.type :Rational, :-@, '() -> Rational'

QDL.type :Rational, :+@, '() -> Rational'

QDL.type :Rational, :**, '(Integer) -> %numeric'
QDL.type :Rational, :**, '(Float) -> %numeric'
QDL.type :Rational, :**, '(Rational) -> %numeric'
QDL.type :Rational, :**, '(BigDecimal) -> BigDecimal'
QDL.pre(:Rational, :**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
QDL.post(:Rational, :**) { |r,x| r.real?}
QDL.type :Rational, :**, '(Complex) -> Complex'
QDL.pre(:Rational, :**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

QDL.type :Rational, :/, '(Integer) -> Rational'
QDL.pre(:Rational, :/) { |x| x!=0}
QDL.type :Rational, :/, '(Float) -> Float'
QDL.pre(:Rational, :/) { |x| x!=0}
QDL.type :Rational, :/, '(Rational) -> Rational'
QDL.pre(:Rational, :/) { |x| x!=0}
QDL.type :Rational, :/, '(BigDecimal) -> BigDecimal'
QDL.pre(:Rational, :/) { |x| x!=0}
QDL.type :Rational, :/, '(Complex) -> Complex'
QDL.pre(:Rational, :/) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Rational, :<, '(Integer) -> %bool'
QDL.type :Rational, :<, '(Float) -> %bool'
QDL.pre(:Rational, :<) { |x| !x.nan?}
QDL.type :Rational, :<, '(Rational) -> %bool'
QDL.type :Rational, :<, '(BigDecimal) -> %bool'
QDL.pre(:Rational, :<) { |x| !x.nan?}

QDL.type :Rational, :<=, '(Integer) -> %bool'
QDL.type :Rational, :<=, '(Float) -> %bool'
QDL.pre(:Rational, :<=) { |x| !x.nan?}
QDL.type :Rational, :<=, '(Rational) -> %bool'
QDL.type :Rational, :<=, '(BigDecimal) -> %bool'
QDL.pre(:Rational, :<=) { |x| !x.nan?}

QDL.type :Rational, :>, '(Integer) -> %bool'
QDL.type :Rational, :>, '(Float) -> %bool'
QDL.pre(:Rational, :>) { |x| !x.nan?}
QDL.type :Rational, :>, '(Rational) -> %bool'
QDL.type :Rational, :>, '(BigDecimal) -> %bool'
QDL.pre(:Rational, :>) { |x| !x.nan?}

QDL.type :Rational, :>=, '(Integer) -> %bool'
QDL.type :Rational, :>=, '(Float) -> %bool'
QDL.pre(:Rational, :>=) { |x| !x.nan?}
QDL.type :Rational, :>=, '(Rational) -> %bool'
QDL.type :Rational, :>=, '(BigDecimal) -> %bool'
QDL.pre(:Rational, :>=) { |x| !x.nan?}

QDL.type :Rational, :<=>, '(Integer) -> Object'
QDL.post(:Rational, :<=>) { |r,x| r == -1 || r==0 || r==1}
QDL.type :Rational, :<=>, '(Float) -> Object'
QDL.post(:Rational, :<=>) { |r,x| r == -1 || r==0 || r==1}
QDL.type :Rational, :<=>, '(Rational) -> Object'
QDL.post(:Rational, :<=>) { |r,x| r == -1 || r==0 || r==1}
QDL.type :Rational, :<=>, '(BigDecimal) -> Object'
QDL.post(:Rational, :<=>) { |r,x| r == -1 || r==0 || r==1}

QDL.type :Rational, :==, '(Object) -> %bool'

QDL.type :Rational, :abs, '() -> Rational'
QDL.post(:Rational, :abs) { |r,x| r >= 0 }

QDL.type :Rational, :abs2, '() -> Rational'
QDL.post(:Rational, :abs2) { |r,x| r >= 0 }

QDL.type :Rational, :angle, '() -> %numeric'
QDL.post(:Rational, :angle) { |r,x| r == 0 || r == Math::PI}

QDL.type :Rational, :arg, '() -> %numeric'
QDL.post(:Rational, :arg) { |r,x| r == 0 || r == Math::PI}

QDL.type :Rational, :div, '(Integer) -> Integer'
QDL.pre(:Rational, :div) { |x| x!=0}
QDL.type :Rational, :div, '(Float) -> Integer'
QDL.pre(:Rational, :div) { |x| x!=0 && !x.nan?}
QDL.type :Rational, :div, '(Rational) -> Integer'
QDL.pre(:Rational, :div) { |x| x!=0}
QDL.type :Rational, :div, '(BigDecimal) -> Integer'
QDL.pre(:Rational, :div) { |x| x!=0 && !x.nan?}

QDL.type :Rational, :modulo, '(Integer) -> Rational'
QDL.pre(:Rational, :modulo) { |x| x!=0}
QDL.type :Rational, :modulo, '(Float) -> Float'
QDL.pre(:Rational, :modulo) { |x| x!=0&&!x.nan?}
QDL.type :Rational, :modulo, '(Rational) -> Rational'
QDL.pre(:Rational, :modulo) { |x| x!=0}
QDL.type :Rational, :modulo, '(BigDecimal) -> BigDecimal'
QDL.pre(:Rational, :modulo) { |x| x!=0&&!x.nan?}

QDL.type :Rational, :ceil, '() -> Integer'
QDL.type :Rational, :ceil, '(Integer) -> %numeric'

QDL.type :Rational, :denominator, '() -> Integer'
QDL.post(:Rational, :denominator) { |r,x| r > 0 }

QDL.type :Rational, :divmod, '(%real) -> [%real, %real]'
QDL.pre(:Rational, :divmod) { |x| x!=0 && if x.is_a?(BigDecimal) then !x.nan? else true end}

QDL.type :Rational, :equal?, '(Object) -> %bool'

QDL.type :Rational, :fdiv, '(Integer) -> Float'
QDL.type :Rational, :fdiv, '(Float) -> Float'
QDL.type :Rational, :fdiv, '(Rational) -> Float'
QDL.type :Rational, :fdiv, '(BigDecimal) -> Float'
QDL.type :Rational, :fdiv, '(Complex) -> Float'
QDL.pre(:Rational, :fdiv) { |x| x.imaginary==0 && x.real.class != Float}

QDL.type :Rational, :floor, '() -> Integer'

QDL.type :Rational, :floor, '(Integer) -> %numeric'

QDL.type :Rational, :hash, '() -> Integer'

QDL.type :Rational, :inspect, '() -> String'

QDL.type :Rational, :numerator, '() -> Integer'

QDL.type :Rational, :phase, '() -> %numeric'

QDL.type :Rational, :quo, '(Integer) -> Rational'
QDL.pre(:Rational, :quo) { |x| x!=0}
QDL.type :Rational, :quo, '(Float) -> Float'
QDL.pre(:Rational, :quo) { |x| x!=0}
QDL.type :Rational, :quo, '(Rational) -> Rational'
QDL.pre(:Rational, :quo) { |x| x!=0}
QDL.type :Rational, :quo, '(BigDecimal) -> BigDecimal'
QDL.pre(:Rational, :quo) { |x| x!=0}
QDL.type :Rational, :quo, '(Complex) -> Complex'
QDL.pre(:Rational, :quo) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Rational, :rationalize, '() -> Rational'

QDL.type :Rational, :rationalize, '(%numeric) -> Rational'
QDL.pre(:Rational, :quo) { |x| if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end}

QDL.type :Rational, :round, '() -> Integer'

QDL.type :Rational, :round, '(Integer) -> %numeric'

QDL.type :Rational, :to_d, "(Integer) -> BigDecimal"

QDL.type :Rational, :to_f, '() -> Float'
QDL.pre(:Rational, :to_f) { self<=Float::MAX}

QDL.type :Rational, :to_i, '() -> Integer'

QDL.type :Rational, :to_r, '() -> Rational'

QDL.type :Rational, :to_s, '() -> String'

QDL.type :Rational, :truncate, '() -> Integer'

QDL.type :Rational, :truncate, '(Integer) -> Rational'

QDL.type :Rational, :zero?, '() -> %bool'

QDL.type :Rational, :conj, '() -> Rational'
QDL.type :Rational, :conjugate, '() -> Rational'

QDL.type :Rational, :imag, '() -> Integer'
QDL.post(:Rational, :imag) { |r,x| r == 0 }
QDL.type :Rational, :imaginary, '() -> Integer'
QDL.post(:Rational, :imaginary) { |r,x| r == 0 }

QDL.type :Rational, :real, '() -> Rational'

QDL.type :Rational, :real?, '() -> true'

QDL.type :Rational, :to_c, '() -> Complex'
QDL.post(:Rational, :to_c) { |r,x| r.imaginary == 0 }

QDL.type :Rational, :coerce, '(Integer) -> [Rational, Rational]'
QDL.type :Rational, :coerce, '(Float) -> [Float, Float]'
QDL.type :Rational, :coerce, '(Rational) -> [Rational, Rational]'
QDL.type :Rational, :coerce, '(Complex) -> [%numeric, %numeric]'
