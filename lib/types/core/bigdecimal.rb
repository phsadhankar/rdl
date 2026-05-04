QDL.nowrap :BigDecimal

class BigDecimal < Numeric; end ## Hacky way around existing issue.
## The issue is any types that even reference BigDecimal, e.g., Integer#+ etc., will
## call const_get on it, but without the above, the class is undefined.
## May want to come up with more elegant solution in the future.

QDL.type :BigDecimal, :%, '(%numeric) -> BigDecimal'
QDL.pre(:BigDecimal, :%) { |x| x!=0&&(if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end)}

QDL.type :BigDecimal, :+, '(Integer) -> BigDecimal'
QDL.type :BigDecimal, :+, '(Float x {{ !x.infinite? && !x.nan? }}) -> BigDecimal'
QDL.type :BigDecimal, :+, '(Rational) -> BigDecimal'
QDL.type :BigDecimal, :+, '(BigDecimal) -> BigDecimal'
QDL.type :BigDecimal, :+, '(Complex) -> Complex'
QDL.pre(:BigDecimal, :+) { |x| if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end}

QDL.type :BigDecimal, :-, '(Integer) -> BigDecimal'
QDL.type :BigDecimal, :-, '(Float x {{ !x.infinite? && !x.nan? }}) -> BigDecimal'
QDL.type :BigDecimal, :-, '(Rational) -> BigDecimal'
QDL.type :BigDecimal, :-, '(BigDecimal) -> BigDecimal'
QDL.type :BigDecimal, :-, '(Complex) -> Complex'
QDL.pre(:BigDecimal, :-) { |x| if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end}

QDL.type :BigDecimal, :-@, '() -> BigDecimal'

QDL.type :BigDecimal, :+@, '() -> BigDecimal'

QDL.type :BigDecimal, :*, '(Integer) -> BigDecimal'
QDL.type :BigDecimal, :*, '(Float x {{ !x.infinite? && !x.nan? }}) -> BigDecimal'
QDL.type :BigDecimal, :*, '(Rational) -> BigDecimal'
QDL.type :BigDecimal, :*, '(BigDecimal) -> BigDecimal'
QDL.type :BigDecimal, :*, '(Complex) -> Complex'
QDL.pre(:BigDecimal, :*) { |x| if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end}

QDL.type :BigDecimal, :**, '(Integer) -> BigDecimal'
QDL.type :BigDecimal, :**, '(Float) -> BigDecimal'
QDL.pre(:BigDecimal, :**) { |x| x!=Float::INFINITY && !x.nan? && if(self<0) then x<=-1||x>=0 else true end}
QDL.type :BigDecimal, :**, '(Rational) -> BigDecimal'
QDL.pre(:BigDecimal, :**) { |x| if(self<0) then x<=-1||x>=0 else true end}
QDL.type :BigDecimal, :**, '(BigDecimal) -> BigDecimal'
QDL.pre(:BigDecimal, :**) { |x| x!=BigDecimal::INFINITY && if(self<0) then x<=-1||x>=0 else true end}

QDL.type :BigDecimal, :/, '(Integer x {{ x!=0 }}) -> BigDecimal'
QDL.type :BigDecimal, :/, '(Float x {{ x!=0 && !x.infinite? && !x.nan? }}) -> BigDecimal'
QDL.type :BigDecimal, :/, '(Rational x {{ x!=0 }}) -> BigDecimal'
QDL.type :BigDecimal, :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
QDL.type :BigDecimal, :/, '(Complex x {{ x!=0 }}) -> Complex'
QDL.pre(:BigDecimal, :/) { |x| if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end && if x.imaginary.is_a?(Float) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end && if (x.real.is_a?(Rational)) then !x.imaginary.nan? else true end}

QDL.type :BigDecimal, :<, '(Integer) -> %bool'
QDL.type :BigDecimal, :<, '(Float x {{ !x.nan? && !x.infinite? }}) -> %bool'
QDL.type :BigDecimal, :<, '(Rational) -> %bool'
QDL.type :BigDecimal, :<, '(BigDecimal) -> %bool'

QDL.type :BigDecimal, :<=, '(Integer) -> %bool'
QDL.type :BigDecimal, :<=, '(Float x {{ !x.nan? && !x.infinite }}) -> %bool'
QDL.type :BigDecimal, :<=, '(Rational) -> %bool'
QDL.type :BigDecimal, :<=, '(BigDecimal) -> %bool'

QDL.type :BigDecimal, :>, '(Integer) -> %bool'
QDL.type :BigDecimal, :>, '(Float x {{ !x.nan? && !x.infinite? }}) -> %bool'
QDL.type :BigDecimal, :>, '(Rational) -> %bool'
QDL.type :BigDecimal, :>, '(BigDecimal) -> %bool'

QDL.type :BigDecimal, :>=, '(Integer) -> %bool'
QDL.type :BigDecimal, :>=, '(Float x {{ !x.nan? && !x.infinite? }}) -> %bool'
QDL.type :BigDecimal, :>=, '(Rational) -> %bool'
QDL.type :BigDecimal, :>=, '(BigDecimal) -> %bool'

QDL.type :BigDecimal, :==, '(Object) -> %bool'
QDL.pre(:BigDecimal, :==) { |x| if (x.is_a?(Float)) then (!x.nan? && x!=Float::INFINITY) else true end}

QDL.type :BigDecimal, :===, '(Object) -> %bool'
QDL.pre(:BigDecimal, :===) { |x| if (x.is_a?(Float)) then (!x.nan? && x!=Float::INFINITY) else true end}

QDL.type :BigDecimal, :<=>, '(Integer) -> Object'
QDL.post(:BigDecimal, :<=>) { |r,x| r == -1 || r==0 || r==1}
QDL.type :BigDecimal, :<=>, '(Float) -> Object'
QDL.pre(:BigDecimal, :<=>) { |x| !x.nan? && x!=Float::INFINITY}
QDL.post(:BigDecimal, :<=>) { |r,x| r == -1 || r==0 || r==1}
QDL.type :BigDecimal, :<=>, '(Rational) -> Object'
QDL.post(:BigDecimal, :<=>) { |r,x| r == -1 || r==0 || r==1}
QDL.type :BigDecimal, :<=>, '(BigDecimal) -> Object'
QDL.post(:BigDecimal, :<=>) { |r,x| r == -1 || r==0 || r==1}

QDL.type :BigDecimal, :abs, '() -> BigDecimal r {{ r>=0 || (if r.nan? then self.nan? end) }}'

QDL.type :BigDecimal, :abs2, '() -> BigDecimal r {{ r>=0 || (if r.nan? then self.nan? end) }}'

QDL.type :BigDecimal, :angle, '() -> %numeric'
QDL.post(:BigDecimal, :angle) { |r,x| r == 0 || r == Math::PI}

QDL.type :BigDecimal, :arg, '() -> %numeric'
QDL.post(:BigDecimal, :arg) { |r,x| r == 0 || r == Math::PI}

QDL.type :BigDecimal, :ceil, '() -> Integer'
QDL.pre(:BigDecimal, :ceil) { !self.infinite? && !self.nan?}

QDL.type :BigDecimal, :conj, '() -> BigDecimal'
QDL.type :BigDecimal, :conjugate, '() -> BigDecimal'

QDL.type :BigDecimal, :denominator, '() -> Integer'
QDL.pre(:BigDecimal, :denominator) { !self.infinite? && !self.nan?}
QDL.post(:BigDecimal, :denominator) { |r,x| r>0}

QDL.type :BigDecimal, :div, '(Integer x {{ x!=0 && !self.infinite? && !self.nan? }}) -> Integer'
QDL.type :BigDecimal, :div, '(Float x {{ x!=0 && !self.infinite? && !self.nan? && !x.infinite? && !x.nan? }}) -> Integer'
QDL.type :BigDecimal, :div, '(Rational x {{ x!=0 && !self.infinite? && !self.nan? }}) -> Integer'
QDL.type :BigDecimal, :div, '(BigDecimal x {{ x!=0 && !self.infinite? && !self.nan? && !x.infinite? && !x.nan? }}) -> Integer'

QDL.type :BigDecimal, :divmod, '(%real) -> [%real, %real]'
QDL.pre(:BigDecimal, :divmod) { |x| x!=0 && if x.is_a?(Float) then !x.nan? && x!=Float::INFINITY else true end}

QDL.type :BigDecimal, :equal?, '(Object) -> %bool'
QDL.type :BigDecimal, :eql?, '(Object) -> %bool'

QDL.type :BigDecimal, :fdiv, '(Integer) -> Float'
QDL.type :BigDecimal, :fdiv, '(Float) -> Float'
QDL.type :BigDecimal, :fdiv, '(Rational) -> Float'
QDL.type :BigDecimal, :fdiv, '(BigDecimal) -> BigDecimal'
QDL.type :BigDecimal, :fdiv, '(Complex) -> Complex'
QDL.pre(:BigDecimal, :fdiv) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :BigDecimal, :finite?, '() -> %bool'

QDL.type :BigDecimal, :floor, '() -> Integer'
QDL.pre(:BigDecimal, :floor) { !self.infinite? && !self.nan?}

QDL.type :BigDecimal, :hash, '() -> Integer'

QDL.type :BigDecimal, :imag, '() -> Integer r {{ r==0 }}'
QDL.type :BigDecimal, :imaginary, '() -> Integer r {{ r==0 }}'

QDL.type :BigDecimal, :infinite?, '() -> NilClass or Integer'

QDL.type :BigDecimal, :to_s, '() -> String'
QDL.type :BigDecimal, :inspect, '() -> String'

QDL.type :BigDecimal, :magnitude, '() -> BigDecimal r {{ r>=0 }}'

QDL.type :BigDecimal, :modulo, '(%numeric) -> BigDecimal'
QDL.pre(:BigDecimal, :modulo) { |x| x!=0&&(if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end)}

QDL.type :BigDecimal, :nan?, '() -> %bool'

QDL.type :BigDecimal, :numerator, '() -> Integer'
QDL.pre(:BigDecimal, :numerator) { !self.infinite? && !self.nan?}

QDL.type :BigDecimal, :phase, '() -> %numeric'

QDL.type :BigDecimal, :quo, '(Integer x {{ x!=0 }}) -> BigDecimal'
QDL.type :BigDecimal, :quo, '(Float x {{ x!=0 && !x.infinite? && !x.nan?}}) -> BigDecimal'
QDL.type :BigDecimal, :quo, '(Rational x {{ x!=0 }}) -> BigDecimal'
QDL.type :BigDecimal, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
QDL.type :BigDecimal, :quo, '(Complex) -> Complex'
QDL.pre(:BigDecimal, :quo) { |x| x!=0 && if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end && if x.imaginary.is_a?(Float) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end && if (x.real.is_a?(Rational)) then !x.imaginary.nan? else true end}

QDL.type :BigDecimal, :real, '() -> BigDecimal'

QDL.type :BigDecimal, :real?, '() -> true'

QDL.type :BigDecimal, :round, '() -> Integer'
QDL.pre(:BigDecimal, :round) { !self.infinite? && !self.nan?}

QDL.type :BigDecimal, :round, '(Integer) -> BigDecimal' #Also, x must be in range [-2**31, 2**31].

QDL.type :BigDecimal, :to_f, '() -> Float'
QDL.pre(:BigDecimal, :to_f) { self<=Float::MAX}

QDL.type :BigDecimal, :to_i, '() -> Integer'
QDL.pre(:BigDecimal, :to_i) { !self.infinite? && !self.nan?}
QDL.type :BigDecimal, :to_int, '() -> Integer'
QDL.pre(:BigDecimal, :to_int) { !self.infinite? && !self.nan?}

QDL.type :BigDecimal, :to_r, '() -> Rational'
QDL.pre(:BigDecimal, :to_r) { !self.infinite? && !self.nan?}

QDL.type :BigDecimal, :to_c, '() -> Complex r {{ r.imaginary == 0 }}'
QDL.post(:BigDecimal, :to_c) { |r,x| r.imaginary == 0 }

QDL.type :BigDecimal, :truncate, '() -> Integer'

QDL.type :BigDecimal, :truncate, '(Integer) -> Rational' #Also, x must be in range [-2**31, 2**31].

QDL.type :BigDecimal, :zero?, '() -> %bool'

QDL.type :BigDecimal, :precs, '() -> [Integer, Integer]'

QDL.type :BigDecimal, :split, '() -> [Integer, String, Integer, Integer]'

QDL.type :BigDecimal, :remainder, '(%real) -> BigDecimal'
QDL.pre(:BigDecimal, :remainder) { |x| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}

QDL.type :BigDecimal, :fix, '() -> BigDecimal'

QDL.type :BigDecimal, :frac, '() -> BigDecimal'

QDL.type :BigDecimal, :power, '(Integer) -> BigDecimal'
QDL.type :BigDecimal, :power, '(Float) -> BigDecimal'
QDL.pre(:BigDecimal, :power) { |x| x!=Float::INFINITY && !x.nan? && if(self<0) then x<=-1||x>=0 else true end}
QDL.type :BigDecimal, :power, '(Rational) -> BigDecimal'
QDL.pre(:BigDecimal, :power) { |x| if(self<0) then x<=-1||x>=0 else true end}
QDL.type :BigDecimal, :power, '(BigDecimal) -> BigDecimal'
QDL.pre(:BigDecimal, :power) { |x| x!=BigDecimal::INFINITY && if(self<0) then x<=-1||x>=0 else true end}

QDL.type :BigDecimal, :nonzero?, '() -> Object'

QDL.type :BigDecimal, :exponent, '() -> Integer'

QDL.type :BigDecimal, :sign, '() -> Integer'

QDL.type :BigDecimal, :_dump, '() -> String'

QDL.type :BigDecimal, :sqrt, '(Integer) -> BigDecimal'
QDL.pre(:BigDecimal, :sqrt) { self>=0}

QDL.type :BigDecimal, :add, '(%real, Integer) -> BigDecimal'
QDL.pre(:BigDecimal, :add) { |x,y| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}

QDL.type :BigDecimal, :sub, '(%real, Integer) -> BigDecimal'
QDL.pre(:BigDecimal, :sub) { |x,y| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}

QDL.type :BigDecimal, :mult, '(%real, Integer) -> BigDecimal'
QDL.pre(:BigDecimal, :mult) { |x,y| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}

QDL.type :BigDecimal, :coerce, '(%real) -> [BigDecimal, BigDecimal]'
QDL.pre(:BigDecimal, :coerce) { |x| if x.is_a?(Float) then !x.nan? && !x.finite? else true end}
