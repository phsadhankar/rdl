QDL.nowrap :Range

# Range is immutable, so covariant
QDL.type_params(:Range, [:t], nil, variance: [:+]) { |t| t.member?(self.begin) && t.member?(self.end) } # TODO: And instantiated if t instantiated

# TODO: Parse error
#QDL.type :Range, :Range, 'self.new', '(begin: [<=> : (u, u) -> Integer], end: [<=>, (u, u) -> Integer], exclude_end: ?%bool) -> Range<u>'
QDL.type :Range, :==, '(%any obj) -> %bool'
QDL.type :Range, :===, '(%any obj) -> %bool'
QDL.type :Range, :begin, '() -> t'
QDL.type :Range, :bsearch, '() { (t) -> %bool } -> u or nil'
QDL.type :Range, :cover?, '(%any obj) -> %bool'
QDL.type :Range, :each, '() { (t) -> %any } -> self'
QDL.type :Range, :each, '() -> Enumerator<t>'
QDL.type :Range, :end, '() -> t'
QDL.qdl_alias :Range, :eql?, :==
QDL.type :Range, :exclude_end?, '() -> %bool'
QDL.type :Range, :first, '() -> t'
QDL.type :Range, :first, '(Integer n) -> Array<t>'
QDL.type :Range, :hash, '() -> Integer'
QDL.type :Range, :include?, '(%any obj) -> %bool'
QDL.type :Range, :initialize, "(x, x) -> self<x>"
QDL.type :Range, :inspect, '() -> String'
QDL.type :Range, :last, '() -> t'
QDL.type :Range, :last, '(Integer n) -> Array<t>'
QDL.type :Range, :max, '() -> t'
QDL.type :Range, :max, '() { (t, t) -> Integer } -> t'
QDL.type :Range, :max, '(Integer n) -> Array<t>'
QDL.type :Range, :max, '(Integer n) { (t, t) -> Integer } -> Array<t>'
QDL.qdl_alias :Range, :member?, :include?
QDL.type :Range, :min, '() -> t'
QDL.type :Range, :min, '() { (t, t) -> Integer } -> t'
QDL.type :Range, :min, '(Integer n) -> Array<t>'
QDL.type :Range, :min, '(Integer n) { (t, t) -> Integer } -> Array<t>'
QDL.type :Range, :size, '() -> Integer or nil'
QDL.type :Range, :step, '(?Integer n) { (t) -> %any } -> self'
QDL.type :Range, :step, '(?Integer n) -> Enumerator<t>'
QDL.type :Range, :to_a, '() -> Array<t>'
QDL.type :Range, :to_ary, '() -> Array<t>'
QDL.type :Range, :to_s, '() -> String'
