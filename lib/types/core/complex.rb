QDL.nowrap :Complex

QDL.type :Complex, :*, '(Integer) -> Complex'
QDL.type :Complex, :*, '(Float) -> Complex'
QDL.pre(:Complex, :*) { |x| if x.infinite?||x.nan? then !self.imaginary.is_a?(BigDecimal)&&!self.real.is_a?(BigDecimal) else true end}
QDL.type :Complex, :*, '(Rational) -> Complex'
QDL.type :Complex, :*, '(BigDecimal) -> Complex'
QDL.pre(:Complex, :*) {if x.real.is_a?(Float) then !x.real.infinite? && !x.real.nan? elsif x.imaginary.is_a?(Float) then !x.imaginary.infinite? && !x.imaginary.nan? else true end}
QDL.type :Complex, :*, '(Complex) -> Complex'
QDL.pre(:Complex, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

QDL.type :Complex, :**, '(Integer) -> Complex'
QDL.type :Complex, :**, '(Float) -> Complex'
QDL.type :Complex, :**, '(Rational) -> Complex'
QDL.type :Complex, :**, '(BigDecimal x {{ !x.infinite? && !x.nan? && x>=0 }}) -> Complex'
QDL.type :Complex, :**, '(Complex) -> Complex'
QDL.pre(:Complex, :**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

QDL.type :Complex, :+, '(Integer) -> Complex'
QDL.type :Complex, :+, '(Float) -> Complex'
QDL.pre(:Complex, :+) { |x| if x.infinite?||x.nan? then !self.real.is_a?(BigDecimal) else true end}
QDL.type :Complex, :+, '(Rational) -> Complex'
QDL.type :Complex, :+, '(BigDecimal) -> Complex'
QDL.pre(:Complex, :+) {if x.real.is_a?(Float) then !x.real.infinite? && !x.real.nan? else true end}
QDL.type :Complex, :+, '(Complex) -> Complex'
QDL.pre(:Complex, :+) { |x| if (x.real.is_a?(BigDecimal) && self.real.is_a?(Float)) then !(self.real.infinite?||self.real.nan?) elsif x.real.is_a?(Float)&&self.real.is_a?(BigDecimal) then !(x.real.infinite?||x.real.nan?) elsif (x.imaginary.is_a?(BigDecimal) && self.imaginary.is_a?(Float)) then !(self.imaginary.infinite?||self.imaginary.nan?) elsif x.imaginary.is_a?(Float)&&self.imaginary.is_a?(BigDecimal) then !(x.imaginary.infinite?||x.imaginary.nan?) else true end}

QDL.type :Complex, :-, '(Integer) -> Complex'
QDL.type :Complex, :-, '(Float) -> Complex'
QDL.pre(:Complex, :-) { |x| if x.infinite?||x.nan? then !self.real.is_a?(BigDecimal) else true end}
QDL.type :Complex, :-, '(Rational) -> Complex'
QDL.type :Complex, :-, '(BigDecimal) -> Complex'
QDL.pre(:Complex, :-) {if x.real.is_a?(Float) then !x.real.infinite? && !x.real.nan? else true end}
QDL.type :Complex, :-, '(Complex) -> Complex'
QDL.pre(:Complex, :-) { |x| if (x.real.is_a?(BigDecimal) && self.real.is_a?(Float)) then !(self.real.infinite?||self.real.nan?) elsif x.real.is_a?(Float)&&self.real.is_a?(BigDecimal) then !(x.real.infinite?||x.real.nan?) elsif (x.imaginary.is_a?(BigDecimal) && self.imaginary.is_a?(Float)) then !(self.imaginary.infinite?||self.imaginary.nan?) elsif x.imaginary.is_a?(Float)&&self.imaginary.is_a?(BigDecimal) then !(x.imaginary.infinite?||x.imaginary.nan?) else true end}

QDL.type :Complex, :-@, '() -> Complex'

QDL.type :Complex, :+@, '() -> Complex'

QDL.type :Complex, :/, '(Integer x {{ x!=0 }}) -> Complex'
QDL.type :Complex, :/, '(Float x {{ x!=0 }}) -> Complex'
QDL.pre(:Complex, :/) { |x| if x.infinte?||x.nan? then !self.real.is_a?(BigDecimal) && !self.imaginary.is_a?(BigDecimal) else true end}
QDL.type :Complex, :/, '(Rational x {{ x!=0 }}) -> Complex'
QDL.type :Complex, :/, '(BigDecimal x {{ x!=0 }}) -> Complex'
QDL.pre(:Complex, :/) { |x| if self.real.is_a?(Float) then !self.real.infinite? && !self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end}
QDL.type :Complex, :/, '(Complex x {{ x!=0 }}) -> Complex'
QDL.pre(:Complex, :/) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal) || self.real.is_a?(BigDecimal) || self.imaginary .is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && if self.real.is_a?(Float) then !self.real.infinite? && !self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Complex, :==, '(Object) -> %bool'

QDL.type :Complex, :abs, '() -> %numeric r {{ r>=0 || (if ((((self.real.is_a? BigDecimal)||(self.real.is_a? Float)) && self.real.nan?) || (((self.imaginary.is_a? BigDecimal)||(self.imaginary.is_a? Float)) && self.imaginary.nan?)) then r.nan? end) }}'

QDL.type :Complex, :abs2, '() -> %numeric r {{ r>=0 || (if ((((self.real.is_a? BigDecimal)||(self.real.is_a? Float)) && self.real.nan?) || (((self.imaginary.is_a? BigDecimal)||(self.imaginary.is_a? Float)) && self.imaginary.nan?)) then r.nan? end) }}'

QDL.type :Complex, :angle, '() -> Float'

QDL.type :Complex, :arg, '() -> Float'

QDL.type :Complex, :conj, '() -> Complex'
QDL.type :Complex, :conjugate, '() -> Complex'

QDL.type :Complex, :denominator, '() -> Integer'

QDL.type :Complex, :equal?, '(Object) -> %bool'
QDL.type :Complex, :eql?, '(Object) -> %bool'

QDL.type :Complex, :fdiv, '(%numeric) -> Complex'
QDL.pre(:Complex, :fdiv) { |x| if (self.real.is_a?(Float) && (self.real.infinite? || self.real.nan?))||(self.imaginary.is_a?(Float) && (self.imaginary.infinite? || self.imaginary.nan?)) then !x.is_a?(BigDecimal) && (if x.is_a?(Complex) then !x.real.is_a?(BigDecimal) && !x.imaginary.is_a?(BigDecimal) else true end) else true end}

QDL.type :Complex, :hash, '() -> Integer'

QDL.type :Complex, :imag, '() -> %real'
QDL.type :Complex, :imaginary, '() -> %real'

QDL.type :Complex, :inspect, '() -> String'

QDL.type :Complex, :magnitude, '() -> %real'

QDL.type :Complex, :numerator, '() -> Complex'

QDL.type :Complex, :phase, '() -> Float'

QDL.type :Complex, :polar, '() -> [%real, %real]'

QDL.type :Complex, :quo, '(Integer x {{ x!=0 }}) -> Complex'
QDL.type :Complex, :quo, '(Float x {{ x!=0 }}) -> Complex'
QDL.pre(:Complex, :quo) { |x| if self.real.is_a?(BigDecimal)||self.imaginary.is_a?(BigDecimal) then !x.infinite? && !x.nan? else true end}
QDL.type :Complex, :quo, '(Rational x {{ x!=0 }}) -> Complex'
QDL.type :Complex, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
QDL.pre(:Complex, :quo) { |x| if self.real.is_a?(Float) then !self.real.infinite?&&!self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end}
QDL.type :Complex, :quo, '(Complex x {{ x!=0 }}) -> Complex'
QDL.pre(:Complex, :quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal) || self.real.is_a?(BigDecimal) || self.imaginary .is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && if self.real.is_a?(Float) then !self.real.infinite? && !self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Complex, :rationalize, '() -> Rational'
QDL.pre(:Complex, :rationalize) { self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

QDL.type :Complex, :rationalize, '(%numeric) -> Rational'
QDL.pre(:Complex, :rationalize) { |x| self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(Rational) then (if x.is_a?(Float)||x.is_a?(BigDecimal) then !x.infinite? && !x.nan? else true end) else true end && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

QDL.type :Complex, :real, '() -> %real'

QDL.type :Complex, :real?, '() -> false'

QDL.type :Complex, :rect, '() -> [%real, %real]'
QDL.type :Complex, :rectangular, '() -> [%real, %real]'

QDL.type :Complex, :to_c, '() -> Complex'

QDL.type :Complex, :to_f, '() -> Float'
QDL.pre(:Complex, :to_f) { self.imaginary==0}

QDL.type :Complex, :to_i, '() -> Integer'
QDL.pre(:Complex, :to_i) { self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

QDL.type :Complex, :to_r, '() -> Rational'
QDL.pre(:Complex, :to_r) { self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

QDL.type :Complex, :to_s, '() -> String'

QDL.type :Complex, :zero?, '() -> %bool'

QDL.type :Complex, :coerce, '(%numeric) -> [Complex, Complex]'
