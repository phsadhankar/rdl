QDL.nowrap :Float

QDL.type :Float, :%, '(Integer x {{ x != 0 }}) -> ``sing_or_type(trec, targs, :%, "Float")``'
QDL.type :Float, :%, '(Float x {{ x != 0 }}) -> ``sing_or_type(trec, targs, :%, "Float")``'
QDL.type :Float, :%, '(Rational x {{ x != 0 }}) -> ``sing_or_type(trec, targs, :%, "Float")``'
QDL.type :Float, :%, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :%, "BigDecimal")``'

QDL.type :Float, :*, '(Integer) -> ``sing_or_type(trec, targs, :*, "Float")``'
QDL.type :Float, :*, '(Float) -> ``sing_or_type(trec, targs, :*, "Float")``'
QDL.type :Float, :*, '(Rational) -> ``sing_or_type(trec, targs, :*, "Float")``'
QDL.type :Float, :*, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :*, "BigDecimal")``'
QDL.type :Float, :*, '(Complex) -> ``sing_or_type(trec, targs, :*, "Complex")``'
QDL.pre(:Float, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

QDL.type :Float, :**, '(Integer) -> ``sing_or_type(trec, targs, :**, "Float")``'
QDL.type :Float, :**, '(Float) -> ``sing_or_type(trec, targs, :**, "%numeric")``'
QDL.type :Float, :**, '(Rational) -> ``sing_or_type(trec, targs, :**, "%numeric")``'
QDL.type :Float, :**, '(BigDecimal) -> ``sing_or_type(trec, targs, :**, "BigDecimal")``'
QDL.pre(:Float, :**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
QDL.post(:Float, :**) { |x| x.real?}
QDL.type :Float, :**, '(Complex) -> ``sing_or_type(trec, targs, :**, "Complex")``'
QDL.pre(:Float, :**) { |x| x != 0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end}

QDL.type :Float, :+, '(Integer) -> ``sing_or_type(trec, targs, :+, "Float")``'
QDL.type :Float, :+, '(Float) -> ``sing_or_type(trec, targs, :+, "Float")``'
QDL.type :Float, :+, '(Rational) -> ``sing_or_type(trec, targs, :+, "Float")``'
QDL.type :Float, :+, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :+, "BigDecimal")``'
QDL.type :Float, :+, '(Complex) -> ``sing_or_type(trec, targs, :+, "Complex")``'
QDL.pre(:Float, :+) { |x| if x.real.is_a?(BigDecimal) then self!=Float::INFINITY && !(self.nan?) else true end}

QDL.type :Float, :-, '(Integer) -> ``sing_or_type(trec, targs, :-, "Float")``'
QDL.type :Float, :-, '(Float) -> ``sing_or_type(trec, targs, :-, "Float")``'
QDL.type :Float, :-, '(Rational) -> ``sing_or_type(trec, targs, :-, "Float")``'
QDL.type :Float, :-, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :-, "BigDecimal")``'
QDL.type :Float, :-, '(Complex) -> ``sing_or_type(trec, targs, :-, "Complex")``'
QDL.pre(:Float, :-) { |x| if x.real.is_a?(BigDecimal) then self!=Float::INFINITY && !(self.nan?) else true end}

QDL.type :Float, :-@, '() -> ``sing_or_type(trec, targs, :-@, "Float")``'

QDL.type :Float, :+@, '() -> ``sing_or_type(trec, targs, :+@, "Float")``'

QDL.type :Float, :/, '(Integer x {{ x != 0 }}) -> ``sing_or_type(trec, targs, :/, "Float")``'
QDL.type :Float, :/, '(Float x {{ x != 0 }}) -> ``sing_or_type(trec, targs, :/, "Float")``'
QDL.type :Float, :/, '(Rational x {{ x != 0 }}) -> ``sing_or_type(trec, targs, :/, "Float")``'
QDL.type :Float, :/, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :/, "BigDecimal")``'
QDL.type :Float, :/, '(Complex x {{ x != 0 }}) -> ``sing_or_type(trec, targs, :/, "Complex")``'
QDL.pre(:Float, :/) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Float, :<, '(Integer) -> ``sing_or_type(trec, targs, :<, "%bool")``'
QDL.type :Float, :<, '(Float) -> ``sing_or_type(trec, targs, :<, "%bool")``'
QDL.type :Float, :<, '(Rational) -> ``sing_or_type(trec, targs, :<, "%bool")``'
QDL.type :Float, :<, '(BigDecimal x {{ !self.nan? && !self.infinite? }}) -> ``sing_or_type(trec, targs, :<, "%bool")``'

QDL.type :Float, :<=, '(Integer) -> ``sing_or_type(trec, targs, :<=, "%bool")``'
QDL.type :Float, :<=, '(Float) -> ``sing_or_type(trec, targs, :<=, "%bool")``'
QDL.type :Float, :<=, '(Rational) -> ``sing_or_type(trec, targs, :<=, "%bool")``'
QDL.type :Float, :<=, '(BigDecimal x {{ !self.nan? && !self.infinite? }}) -> ``sing_or_type(trec, targs, :<=, "%bool")``'

QDL.type :Float, :<=>, '(Integer) -> ``sing_or_type(trec, targs, :<=>, "Integer")``'
QDL.post(:Float, :<=>) { |x| x == -1 || x==0 || x==1}
QDL.type :Float, :<=>, '(Float) -> ``sing_or_type(trec, targs, :<=>, "Integer")``'
QDL.post(:Float, :<=>) { |x| x == -1 || x==0 || x==1}
QDL.type :Float, :<=>, '(Rational) -> ``sing_or_type(trec, targs, :<=>, "Integer")``'
QDL.post(:Float, :<=>) { |x| x == -1 || x==0 || x==1}
QDL.type :Float, :<=>, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :<=>, "Integer")``'
QDL.post(:Float, :<=>) { |x| x == -1 || x==0 || x==1}

QDL.type :Float, :==, '(Object) -> ``sing_or_type(trec, targs, :==, "%bool")``'
QDL.pre(:Float, :==) { |x| if (x.is_a?(BigDecimal)) then (!self.nan? && self!=Float::INFINITY) else true end}

QDL.type :Float, :===, '(Object) -> ``sing_or_type(trec, targs, :===, "%bool")``'
QDL.pre(:Float, :===) { |x| if (x.is_a?(BigDecimal)) then (!self.nan? && self!=Float::INFINITY) else true end}

QDL.type :Float, :>, '(Integer) -> ``sing_or_type(trec, targs, :>, "%bool")``'
QDL.type :Float, :>, '(Float) -> ``sing_or_type(trec, targs, :>, "%bool")``'
QDL.type :Float, :>, '(Rational) -> ``sing_or_type(trec, targs, :>, "%bool")``'
QDL.type :Float, :>, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :>, "%bool")``'

QDL.type :Float, :>=, '(Integer) -> ``sing_or_type(trec, targs, :>=, "%bool")``'
QDL.type :Float, :>=, '(Float) -> ``sing_or_type(trec, targs, :>=, "%bool")``'
QDL.type :Float, :>=, '(Rational) -> ``sing_or_type(trec, targs, :>=, "%bool")``'
QDL.type :Float, :>=, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :>=, "%bool")``'

QDL.type :Float, :abs, '() -> Float r {{ r>=0 || (if self.nan? then r.nan? end) }}' ## TODO

QDL.type :Float, :abs2, '() -> Float r {{ r>=0 || (if self.nan? then r.nan? end) }}' ## TODO

QDL.type :Float, :div, '(Integer x {{ x != 0 && !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :div, "Integer")``'
QDL.type :Float, :div, '(Float x {{ x != 0 && !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :div, "Integer")``'
QDL.type :Float, :div, '(Rational x {{ x != 0 && !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :div, "Integer")``'
QDL.type :Float, :div, '(BigDecimal x {{ x != 0 && !x.nan? && !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :div, "Integer")``'

QDL.type :Float, :divmod, '(%real) -> [%real, %real]'
QDL.pre(:Float, :divmod) { |x| x != 0 && if x.is_a?(Float) then !x.nan? else true end && self!=Float::INFINITY && !self.nan?}

QDL.type :Float, :angle, '() -> ``sing_or_type(trec, targs, :angle, "%numeric")``'
QDL.post(:Float, :angle) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

QDL.type :Float, :arg, '() -> ``sing_or_type(trec, targs, :rg, "%numeric")``'
QDL.post(:Float, :arg) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

QDL.type :Float, :ceil, '() -> ``sing_or_type(trec, targs, :ceil, "Integer")``'
QDL.pre(:Float, :ceil) { !self.infinite? && !self.nan?}

QDL.type :Float, :coerce, '(%real) -> [Float, Float]'

QDL.type :Float, :denominator, '() -> Integer r {{ r>0 }}' ## TODO

QDL.type :Float, :equal?, '(Object) -> ``sing_or_type(trec, targs, :equal?, "%bool")``'

QDL.type :Float, :eql?, '(Object) -> ``sing_or_type(trec, targs, :eql?, "%bool")``'

QDL.type :Float, :fdiv, '(Integer) -> ``sing_or_type(trec, targs, :fdiv, "Float")``'
QDL.type :Float, :fdiv, '(Float) -> ``sing_or_type(trec, targs, :fdiv, "Float")``'
QDL.type :Float, :fdiv, '(Rational) -> ``sing_or_type(trec, targs, :fdiv, "Float")``'
QDL.type :Float, :fdiv, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :fdiv, "BigDecimal")``'
QDL.type :Float, :fdiv, '(Complex) -> ``sing_or_type(trec, targs, :fdiv, "Complex")``'
QDL.pre(:Float, :fdiv) { |x| x != 0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Float, :finite?, '() -> ``sing_or_type(trec, targs, :finite?, "%bool")``'

QDL.type :Float, :floor, '() -> ``sing_or_type(trec, targs, :floor, "Integer")``'
QDL.pre(:Float, :ceil) { !self.infinite? && !self.nan?}

QDL.type :Float, :hash, '() -> Integer'

QDL.type :Float, :infinite?, '() -> ``sing_or_type(trec, targs, :infinite?, "Integer")``'
QDL.post(:Float, :infinite?) { |r,x| r == -1 || r == 1 || r == nil }

QDL.type :Float, :to_s, '() -> String'
QDL.type :Float, :inspect, '() -> String'

QDL.type :Float, :magnitude, '() -> ``sing_or_type(trec, targs, :magnitude, "Float")``'
QDL.post(:Float, :magnitude) { |r,x| r>=0 }

QDL.type :Float, :modulo, '(Integer x {{ x != 0 }}) -> ``sing_or_type(trec, targs, :modulo, "Float")``'
QDL.type :Float, :modulo, '(Float x {{ x != 0 }}) -> ``sing_or_type(trec, targs, :modulo, "Float")``'
QDL.type :Float, :modulo, '(Rational x {{ x != 0 }}) -> ``sing_or_type(trec, targs, :modulo, "Float")``'
QDL.type :Float, :modulo, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :modulo, "BigDecimal")``'

QDL.type :Float, :nan?, '() -> ``sing_or_type(trec, targs, :nan?, "%bool")``'

QDL.type :Float, :next_float, '() -> ``sing_or_type(trec, targs, :next_float, "Float")``'

QDL.type :Float, :numerator, '() -> ``sing_or_type(trec, targs, :numerator, "Integer")``'

QDL.type :Float, :phase, '() -> ``sing_or_type(trec, targs, :phase, "%numeric")``'
QDL.post(:Float, :phase) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

QDL.type :Float, :prev_float, '() -> ``sing_or_type(trec, targs, :prev_float, "Float")``'

QDL.type :Float, :quo, '(Integer x {{ x != 0 }}) -> ``sing_or_type(trec, targs, :quo, "Float")``'
QDL.type :Float, :quo, '(Float x {{ x != 0 }}) -> ``sing_or_type(trec, targs, :quo, "Float")``'
QDL.type :Float, :quo, '(Rational x {{ x != 0 }}) -> ``sing_or_type(trec, targs, :quo, "Float")``'
QDL.type :Float, :quo, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> ``sing_or_type(trec, targs, :quo, "BigDecimal")``'
QDL.type :Float, :quo, '(Complex x {{ x != 0 }}) -> ``sing_or_type(trec, targs, :quo, "Complex")``'
QDL.pre(:Float, :quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Float, :rationalize, '() -> ``sing_or_type(trec, targs, :rationalize, "Rational")``'
QDL.pre(:Float, :rationalize) { !self.infinite? && !self.nan?}

QDL.type :Float, :rationalize, '(%numeric) -> ``sing_or_type(trec, targs, :rationalize, "Rational")``'
QDL.pre(:Float, :rationalize) { |x| if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end}

QDL.type :Float, :round, '() -> ``sing_or_type(trec, targs, :round, "Integer")``'
QDL.pre(:Float, :round) { !self.infinite? && !self.nan?}

QDL.type :Float, :round, '(%numeric) -> ``sing_or_type(trec, targs, :round, "%numeric")``'
QDL.pre(:Float, :round) { |x| x != 0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

QDL.type :Float, :to_f, '() -> self'

QDL.type :Float, :to_i, '() -> ``sing_or_type(trec, targs, :to_i, "Integer")``'
QDL.pre(:Float, :to_i) { !self.infinite? && !self.nan?}

QDL.type :Float, :to_int, '() -> ``sing_or_type(trec, targs, :to_int, "Integer")``'
QDL.pre(:Float, :to_int) { !self.infinite? && !self.nan?}

QDL.type :Float, :to_r, '() -> ``sing_or_type(trec, targs, :to_r, "Rational")``'
QDL.pre(:Float, :to_r) { !self.infinite? && !self.nan?}

QDL.type :Float, :truncate, '() -> ``sing_or_type(trec, targs, :truncate, "Integer")``'

QDL.type :Float, :zero?, '() -> ``sing_or_type(trec, targs, :zero, "%bool")``'

QDL.type :Float, :conj, '() -> ``sing_or_type(trec, targs, :conj, "Float")``'
QDL.type :Float, :conjugate, '() -> ``sing_or_type(trec, targs, :conjugate, "Float")``'

QDL.type :Float, :imag, '() -> Integer r {{ r==0 }}' ## TODO 
QDL.type :Float, :imaginary, '() -> Integer r {{ r==0 }}'  ## TODO

QDL.type :Float, :real, '() -> ``sing_or_type(trec, targs, :real, "Float")``'

QDL.type :Float, :real?, '() -> ``sing_or_type(trec, targs, :real?, "%bool")``'

QDL.type :Float, :to_c, '() -> Complex r {{ r.imaginary == 0 }}' ## TODO

QDL.type :Float, :coerce, '(%numeric) -> [Float, Float]'
QDL.pre(:Float, :coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}



######### Non-dependent types below #########


QDL.type :Float, :%, '(Integer x {{ x != 0 }}) -> Float'
QDL.type :Float, :%, '(Float x {{ x != 0 }}) -> Float'
QDL.type :Float, :%, '(Rational x {{ x != 0 }}) -> Float'
QDL.type :Float, :%, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> BigDecimal'

QDL.type :Float, :*, '(Integer) -> Float'
QDL.type :Float, :*, '(Float) -> Float'
QDL.type :Float, :*, '(Rational) -> Float'
QDL.type :Float, :*, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> BigDecimal'
QDL.type :Float, :*, '(Complex) -> Complex'
QDL.pre(:Float, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

QDL.type :Float, :**, '(Integer) -> Float'
QDL.type :Float, :**, '(Float) -> %numeric'
QDL.type :Float, :**, '(Rational) -> %numeric'
QDL.type :Float, :**, '(BigDecimal) -> BigDecimal'
QDL.pre(:Float, :**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
QDL.post(:Float, :**) { |x| x.real?}
QDL.type :Float, :**, '(Complex) -> Complex'
QDL.pre(:Float, :**) { |x| x != 0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end}

QDL.type :Float, :+, '(Integer) -> Float'
QDL.type :Float, :+, '(Float) -> Float'
QDL.type :Float, :+, '(Rational) -> Float'
QDL.type :Float, :+, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> BigDecimal'
QDL.type :Float, :+, '(Complex) -> Complex'
QDL.pre(:Float, :+) { |x| if x.real.is_a?(BigDecimal) then self!=Float::INFINITY && !(self.nan?) else true end}

QDL.type :Float, :-, '(Integer) -> Float'
QDL.type :Float, :-, '(Float) -> Float'
QDL.type :Float, :-, '(Rational) -> Float'
QDL.type :Float, :-, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> BigDecimal'
QDL.type :Float, :-, '(Complex) -> Complex'
QDL.pre(:Float, :-) { |x| if x.real.is_a?(BigDecimal) then self!=Float::INFINITY && !(self.nan?) else true end}

QDL.type :Float, :-@, '() -> Float'

QDL.type :Float, :+@, '() -> Float'

QDL.type :Float, :/, '(Integer x {{ x != 0 }}) -> Float'
QDL.type :Float, :/, '(Float x {{ x != 0 }}) -> Float'
QDL.type :Float, :/, '(Rational x {{ x != 0 }}) -> Float'
QDL.type :Float, :/, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> BigDecimal'
QDL.type :Float, :/, '(Complex x {{ x != 0 }}) -> Complex'
QDL.pre(:Float, :/) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Float, :<, '(Integer) -> %bool'
QDL.type :Float, :<, '(Float) -> %bool'
QDL.type :Float, :<, '(Rational) -> %bool'
QDL.type :Float, :<, '(BigDecimal x {{ !self.nan? && !self.infinite? }}) -> %bool'

QDL.type :Float, :<=, '(Integer) -> %bool'
QDL.type :Float, :<=, '(Float) -> %bool'
QDL.type :Float, :<=, '(Rational) -> %bool'
QDL.type :Float, :<=, '(BigDecimal x {{ !self.nan? && !self.infinite? }}) -> %bool'

QDL.type :Float, :<=>, '(Integer) -> Object'
QDL.post(:Float, :<=>) { |x| x == -1 || x==0 || x==1}
QDL.type :Float, :<=>, '(Float) -> Object'
QDL.post(:Float, :<=>) { |x| x == -1 || x==0 || x==1}
QDL.type :Float, :<=>, '(Rational) -> Object'
QDL.post(:Float, :<=>) { |x| x == -1 || x==0 || x==1}
QDL.type :Float, :<=>, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> Object'
QDL.post(:Float, :<=>) { |x| x == -1 || x==0 || x==1}

QDL.type :Float, :==, '(Object) -> %bool'
QDL.pre(:Float, :==) { |x| if (x.is_a?(BigDecimal)) then (!self.nan? && self!=Float::INFINITY) else true end}

QDL.type :Float, :===, '(Object) -> %bool'
QDL.pre(:Float, :===) { |x| if (x.is_a?(BigDecimal)) then (!self.nan? && self!=Float::INFINITY) else true end}

QDL.type :Float, :>, '(Integer) -> %bool'
QDL.type :Float, :>, '(Float) -> %bool'
QDL.type :Float, :>, '(Rational) -> %bool'
QDL.type :Float, :>, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> %bool'

QDL.type :Float, :>=, '(Integer) -> %bool'
QDL.type :Float, :>=, '(Float) -> %bool'
QDL.type :Float, :>=, '(Rational) -> %bool'
QDL.type :Float, :>=, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> %bool'

QDL.type :Float, :abs, '() -> Float r {{ r>=0 || (if self.nan? then r.nan? end) }}'

QDL.type :Float, :abs2, '() -> Float r {{ r>=0 || (if self.nan? then r.nan? end) }}'

QDL.type :Float, :div, '(Integer x {{ x != 0 && !self.infinite? && !self.nan? }}) -> Integer'
QDL.type :Float, :div, '(Float x {{ x != 0 && !self.infinite? && !self.nan? }}) -> Integer'
QDL.type :Float, :div, '(Rational x {{ x != 0 && !self.infinite? && !self.nan? }}) -> Integer'
QDL.type :Float, :div, '(BigDecimal x {{ x != 0 && !x.nan? && !self.infinite? && !self.nan? }}) -> Integer'

QDL.type :Float, :divmod, '(%real) -> [%real, %real]'
QDL.pre(:Float, :divmod) { |x| x != 0 && if x.is_a?(Float) then !x.nan? else true end && self!=Float::INFINITY && !self.nan?}

QDL.type :Float, :angle, '() -> %numeric'
QDL.post(:Float, :angle) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

QDL.type :Float, :arg, '() -> %numeric'
QDL.post(:Float, :arg) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

QDL.type :Float, :ceil, '() -> Integer'
QDL.pre(:Float, :ceil) { !self.infinite? && !self.nan?}

QDL.type :Float, :coerce, '(%real) -> [Float, Float]'

QDL.type :Float, :denominator, '() -> Integer r {{ r>0 }}'

QDL.type :Float, :equal?, '(Object) -> %bool'

QDL.type :Float, :eql?, '(Object) -> %bool'

QDL.type :Float, :fdiv, '(Integer) -> Float'
QDL.type :Float, :fdiv, '(Float) -> Float'
QDL.type :Float, :fdiv, '(Rational) -> Float'
QDL.type :Float, :fdiv, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> BigDecimal'
QDL.type :Float, :fdiv, '(Complex) -> Complex'
QDL.pre(:Float, :fdiv) { |x| x != 0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Float, :finite?, '() -> %bool'

QDL.type :Float, :floor, '() -> Integer'
QDL.pre(:Float, :ceil) { !self.infinite? && !self.nan?}

QDL.type :Float, :hash, '() -> Integer'

QDL.type :Float, :infinite?, '() -> Object'
QDL.post(:Float, :infinite?) { |r,x| r == -1 || r == 1 || r == nil }

QDL.type :Float, :to_s, '() -> String'
QDL.type :Float, :inspect, '() -> String'

QDL.type :Float, :magnitude, '() -> Float'
QDL.post(:Float, :magnitude) { |r,x| r>=0 }

QDL.type :Float, :modulo, '(Integer x {{ x != 0 }}) -> Float'
QDL.type :Float, :modulo, '(Float x {{ x != 0 }}) -> Float'
QDL.type :Float, :modulo, '(Rational x {{ x != 0 }}) -> Float'
QDL.type :Float, :modulo, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> BigDecimal'

QDL.type :Float, :nan?, '() -> %bool'

QDL.type :Float, :next_float, '() -> Float'

QDL.type :Float, :numerator, '() -> Integer'

QDL.type :Float, :phase, '() -> %numeric'
QDL.post(:Float, :phase) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

QDL.type :Float, :prev_float, '() -> Float'

QDL.type :Float, :quo, '(Integer x {{ x != 0 }}) -> Float'
QDL.type :Float, :quo, '(Float x {{ x != 0 }}) -> Float'
QDL.type :Float, :quo, '(Rational x {{ x != 0 }}) -> Float'
QDL.type :Float, :quo, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> BigDecimal'
QDL.type :Float, :quo, '(Complex x {{ x != 0 }}) -> Complex'
QDL.pre(:Float, :quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

QDL.type :Float, :rationalize, '() -> Rational'
QDL.pre(:Float, :rationalize) { !self.infinite? && !self.nan?}

QDL.type :Float, :rationalize, '(%numeric) -> Rational'
QDL.pre(:Float, :rationalize) { |x| if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end}

QDL.type :Float, :round, '() -> Integer'
QDL.pre(:Float, :round) { !self.infinite? && !self.nan?}

QDL.type :Float, :round, '(%numeric) -> %numeric'
QDL.pre(:Float, :round) { |x| x != 0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

QDL.type :Float, :to_f, '() -> Float'

QDL.type :Float, :to_i, '() -> Integer'
QDL.pre(:Float, :to_i) { !self.infinite? && !self.nan?}

QDL.type :Float, :to_int, '() -> Integer'
QDL.pre(:Float, :to_int) { !self.infinite? && !self.nan?}

QDL.type :Float, :to_r, '() -> Rational'
QDL.pre(:Float, :to_r) { !self.infinite? && !self.nan?}

QDL.type :Float, :truncate, '() -> Integer'

QDL.type :Float, :zero?, '() -> %bool'

QDL.type :Float, :conj, '() -> Float'
QDL.type :Float, :conjugate, '() -> Float'

QDL.type :Float, :imag, '() -> Integer r {{ r==0 }}'
QDL.type :Float, :imaginary, '() -> Integer r {{ r==0 }}'

QDL.type :Float, :real, '() -> Float'

QDL.type :Float, :real?, '() -> true'

QDL.type :Float, :to_c, '() -> Complex r {{ r.imaginary == 0 }}'

QDL.type :Float, :coerce, '(%numeric) -> [Float, Float]'
QDL.pre(:Float, :coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
