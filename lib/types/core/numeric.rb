QDL.nowrap :Numeric

QDL.type :Numeric, :%, '(%numeric) -> %numeric'
QDL.pre(:Numeric, :%) { |x| x!=0}
QDL.type :Numeric, :-@, '() -> %numeric'
QDL.type :Numeric, :+@, '() -> %numeric'
QDL.type :Numeric, :<=>, '(%numeric) -> Object'
QDL.post(:Numeric, :<=>) { |r,x| r == -1 || r==0 || r==1 || r==nil}
QDL.type :Numeric, :abs, '() -> %numeric'
QDL.post(:Numeric, :abs) { |r,x| r >= 0 }
QDL.type :Numeric, :abs2, '() -> %numeric'
QDL.post(:Numeric, :abs2) { |r,x| r >= 0 }
QDL.type :Numeric, :angle, '() -> %numeric'
QDL.type :Numeric, :arg, '() -> %numeric'
QDL.type :Numeric, :ceil, '() -> Integer'
QDL.type :Numeric, :coerce, '(%numeric) -> [%numeric, %numeric]'
QDL.type :Numeric, :conj, '() -> %numeric'
QDL.type :Numeric, :conjugate, '() -> %numeric'
QDL.type :Numeric, :denominator, '() -> Integer'
QDL.post(:Numeric, :denominator) { |r,x| r >= 0 }
QDL.type :Numeric, :div, '(%numeric) -> Integer'
QDL.pre(:Numeric, :div) { |x| x!=0}
QDL.type :Numeric, :divmod, '(%numeric) -> [%numeric, %numeric]'
QDL.pre(:Numeric, :divmod) { |x| x!=0 }
QDL.type :Numeric, :eql?, '(%numeric) -> %bool'
QDL.type :Numeric, :fdiv, '(%numeric) -> %numeric'
QDL.type :Numeric, :floor, '() -> Integer'
QDL.type :Numeric, :i, '() -> Complex'
QDL.type :Numeric, :imag, '() -> %numeric'
QDL.type :Numeric, :imaginary, '() -> %numeric'
QDL.type :Numeric, :integer?, '() -> %bool'
QDL.type :Numeric, :magnitude, '() -> %numeric'
QDL.type :Numeric, :modulo, '(%numeric) -> %real'
QDL.pre(:Numeric, :modulo) { |x| x!=0 }
QDL.type :Numeric, :nonzero?, '() -> self or nil'
QDL.type :Numeric, :numerator, '() -> Integer'
QDL.type :Numeric, :phase, '() -> %numeric'
QDL.type :Numeric, :polar, '() -> [%numeric, %numeric]'
QDL.type :Numeric, :quo, '(%numeric) -> %numeric'
QDL.type :Numeric, :real, '() -> %numeric'
QDL.type :Numeric, :real?, '() -> %numeric'
QDL.type :Numeric, :rect, '() -> [%numeric, %numeric]'
QDL.type :Numeric, :rectangular, '() -> [%numeric, %numeric]'
QDL.type :Numeric, :remainder, '(%numeric) -> %real'
QDL.type :Numeric, :round, '(%numeric) -> %numeric'
QDL.type :Numeric, :singleton_method_added, '(Symbol) -> TypeError'
QDL.type :Numeric, :step, '(%numeric) { (?%numeric) -> %any } -> %numeric'
QDL.type :Numeric, :step, '(%numeric) -> Enumerator<%numeric>'
QDL.type :Numeric, :step, '(%numeric, %numeric) { (?%numeric) -> %any } -> %numeric'
QDL.type :Numeric, :step, '(%numeric, %numeric) -> Enumerator<%numeric>'
QDL.type :Numeric, :to_c, '() -> Complex'
QDL.type :Numeric, :to_int, '() -> Integer'
QDL.type :Numeric, :truncate, '() -> Integer'
QDL.type :Numeric, :zero?, '() -> %bool'
