QDL.nowrap :Proc

QDL.type :Proc, :arity, '() -> Integer'
QDL.type :Proc, :binding, '() -> Binding'
QDL.type :Proc, :curry, '(?Integer arity) -> Proc'
QDL.type :Proc, :hash, '() -> Integer'
QDL.qdl_alias :Proc, :inspect, :to_s
QDL.type :Proc, :lambda, '() -> %bool'
QDL.type :Proc, :parameters, '() -> Array<[Symbol, Symbol]>'
QDL.type :Proc, :source_location, '() -> [String, Integer]'
QDL.type :Proc, :to_proc, '() -> self'
QDL.type :Proc, :to_s, '() -> String'
