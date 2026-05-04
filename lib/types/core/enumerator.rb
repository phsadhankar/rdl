QDL.nowrap :Enumerator

QDL.type_params :Enumerator, [:t], :all?

QDL.type :Enumerator, :initialize, '(?Integer) { (Array<u>) -> %any } -> self<u>'
QDL.type :Enumerator, :initialize, '(?Proc) { (Array<u>) -> %any } -> self<u>' # TODO Proc
# TODO: deprecated form of new
QDL.type :Enumerator, :each, '() { (t) -> %any } -> %any' # is there a better QDL.type?
QDL.type :Enumerator, :each, '() -> self'
# TODO: args
QDL.type :Enumerator, :each_with_index, '() { (t, Integer) -> %any } -> %any' # TODO args
QDL.type :Enumerator, :each_with_index, '() -> Enumerator<[t, Integer]>' # TODO args
QDL.type :Enumerator, :each_with_object, '(u) { (t, u) -> %any } -> %any' # TODO args
QDL.type :Enumerator, :each_with_object, '(u) -> Enumerator<[t, u]>' # TODO args
QDL.type :Enumerator, :feed, '(t) -> nil'
QDL.type :Enumerator, :inspect, '() -> String'
QDL.type :Enumerator, :next, '() -> t'
QDL.type :Enumerator, :next_values, '() -> Array<t>'
QDL.type :Enumerator, :peek, '() -> t'
QDL.type :Enumerator, :peek_values, '() -> Array<t>'
QDL.type :Enumerator, :rewind, '() -> self'
QDL.type :Enumerator, :size, '() -> Integer or Float or nil'
QDL.type :Enumerator, :with_index, "(?Integer) -> self"
QDL.type :Enumerator, :with_index, "(?Integer) { (t, Integer) -> %any } -> %any"
QDL.qdl_alias :Enumerator, :with_object, :each_with_object
