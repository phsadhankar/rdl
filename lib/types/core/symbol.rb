QDL.nowrap :Symbol

QDL.type :Symbol, 'self.all_symbols', '() -> Array<Symbol>'
QDL.type :Symbol, :<=>, '(Symbol other) -> Integer or nil'
QDL.type :Symbol, :==, '(Object) -> %bool'
QDL.type :Symbol, :=~, '(Object) -> Integer or nil'
QDL.type :Symbol, :[], '(Integer idx) -> String'
QDL.type :Symbol, :[], '(Integer b, Integer n) -> String'
QDL.type :Symbol, :[], '(Range<Integer>) -> String'
QDL.type :Symbol, :capitalize, '() -> Symbol'
QDL.type :Symbol, :casecmp, '(Symbol other) -> Integer or nil'
QDL.type :Symbol, :downcase, '() -> Symbol'
QDL.type :Symbol, :empty?, '() -> %bool'
QDL.type :Symbol, :encoding, '() -> Encoding'
QDL.type :Symbol, :id2name, '() -> String'
QDL.type :Symbol, :inspect, '() -> String'
QDL.type :Symbol, :intern, '() -> self'
QDL.type :Symbol, :length, '() -> Integer'
QDL.type :Symbol, :match, '(%any obj) -> Integer or nil'
QDL.type :Symbol, :succ, '() -> Symbol'
QDL.qdl_alias :Symbol, :size, :length
QDL.qdl_alias :Symbol, :slice, :[]
QDL.type :Symbol, :swapcase, '() -> Symbol'
QDL.type :Symbol, :to_proc, '() -> Proc' # TODO proc
QDL.type :Symbol, :to_s, "() -> String"
QDL.type :Symbol, :to_sym, "() -> self"
QDL.type :Symbol, :upcase, '() -> Symbol'
