QDL.nowrap :Enumerable

QDL.type_params :Enumerable, [:t], :all?

QDL.type :Enumerable, :all?, '() -> %bool'
QDL.type :Enumerable, :all?, '() { (t) -> %bool } -> %bool'
QDL.type :Enumerable, :all?, '() { (k, v) -> %bool } -> %bool'
QDL.type :Enumerable, :all?, '([ ===: (%any) -> %bool]) -> %bool'
QDL.type :Enumerable, :any?, '() -> %bool'
QDL.type :Enumerable, :any?, '() { (t) -> %any } -> %bool'
# QDL.type :Enumerable, :chunk, '(XXXX : *XXXX)' # TODO
QDL.type :Enumerable, :collect, '() { (t) -> u } -> Array<u>'
QDL.type :Enumerable, :collect, '() { () -> u } -> Array<u>'
QDL.type :Enumerable, :collect, '() { (k, v) -> u } -> Array<u>'
QDL.type :Enumerable, :collect, '() -> Enumerator<t>'
# QDL.type :Enumerable, :collect_concat # TODO
QDL.type :Enumerable, :count, '() -> Integer'
QDL.type :Enumerable, :count, '(%any) -> Integer'
QDL.type :Enumerable, :count, '() { (t) -> %bool } -> Integer'
QDL.type :Enumerable, :cycle, '(?Integer n) { (t) -> %any } -> nil'
QDL.type :Enumerable, :cycle, '(?Integer n) -> Enumerator<t>'
QDL.type :Enumerable, :detect, '(?Proc ifnone) { (t) -> %bool } -> t or nil' # TODO ifnone
QDL.type :Enumerable, :detect, '() { (t) -> %bool } -> t or nil' # TODO ifnone
QDL.type :Enumerable, :detect, '(?Proc ifnone) -> Enumerator<t>'
QDL.type :Enumerable, :drop, '(Integer n) -> Array<t>'
QDL.type :Enumerable, :drop_while, '() { (t) -> %bool } -> Array<t>'
QDL.type :Enumerable, :drop_while, '() -> Enumerator<t>'
QDL.type :Enumerable, :each_cons, '(Integer n) { (Array<t>) -> %any } -> nil'
QDL.type :Enumerable, :each_cons, '(Integer n) -> Enumerator<t>'
# QDL.type :Enumerable, :each_entry, '(XXXX : *XXXX)' # TODO
QDL.qdl_alias :Enumerable, :each_slice, :each_cons
QDL.type :Enumerable, :each_with_index, '() { (t, Integer) -> %any } -> Enumerable<t>'
QDL.type :Enumerable, :each_with_index, '() -> Enumerable<t>' # args! note may not return self
# QDL.type :Enumerable, :each_with_object, '(XXXX : XXXX)' #TODO
QDL.type :Enumerable, :entries, '() -> Array<t>' # TODO args?
QDL.qdl_alias :Enumerable, :find, :detect
QDL.type :Enumerable, :find_all, '() { (t) -> %bool } -> Array<t>'
QDL.type :Enumerable, :find_all, '() -> Enumerator<t>'
QDL.type :Enumerable, :find_index, '(%any value) -> Integer or nil'
QDL.type :Enumerable, :find_index, '() { (t) -> %bool } -> Integer or nil'
QDL.type :Enumerable, :find_index, '() -> Enumerator<t>'
QDL.type :Enumerable, :first, '() -> t or nil'
QDL.type :Enumerable, :first, '(Integer n) -> Array<t> or nil'
#  QDL.qdl_alias :Enumerable, :flat_map, :collect_concat
QDL.type :Enumerable, :grep, '(%any) -> Array<t>'
QDL.type :Enumerable, :grep, '(%any) { (t) -> u } -> Array<u>'
QDL.type :Enumerable, :group_by, '() { (t) -> u } -> Hash<u, Array<t>>'
QDL.type :Enumerable, :group_by, '() -> Enumerator<t>'
QDL.type :Enumerable, :include?, '(%any) -> %bool'
QDL.type :Enumerable, :inject, '(any initial, Symbol) -> %any' # can't tell initial, return QDL.type; not enough info in Symbol
QDL.type :Enumerable, :inject, '(Symbol) -> %any'
QDL.type :Enumerable, :inject, '(u initial) { (u, t) -> u } -> u'
QDL.type :Enumerable, :inject, '() { (t, t) -> t } -> t' # if initial not given, first element is initial
# QDL.type :Enumerable, :lazy # TODO
QDL.qdl_alias :Enumerable, :map, :collect
QDL.type :Enumerable, :max, '() -> t'
QDL.type :Enumerable, :max, '() { (t, t) -> Integer } -> t'
QDL.type :Enumerable, :max, '(Integer) -> Array<t>'
QDL.type :Enumerable, :max, '(Integer) { (t, t) -> Integer } -> Array<t>'
QDL.type :Enumerable, :max_by, '() -> Enumerator<t>'
QDL.type :Enumerable, :max_by, '() { (t) -> Integer } -> t'
QDL.type :Enumerable, :max_by, '(Integer) -> Enumerator<t>'
QDL.type :Enumerable, :max_by, '(Integer) { (t) -> Integer } -> Array<t>'
QDL.qdl_alias :Enumerable, :member?, :include?
QDL.type :Enumerable, :min, '() -> t'
QDL.type :Enumerable, :min, '() { (t, t) -> Integer } -> t'
QDL.type :Enumerable, :min, '(Integer) -> Array<t>'
QDL.type :Enumerable, :min, '(Integer) { (t, t) -> Integer } -> Array<t>'
QDL.type :Enumerable, :min_by, '() -> Enumerator<t>'
QDL.type :Enumerable, :min_by, '() { (t, t) -> Integer } -> t'
QDL.type :Enumerable, :min_by, '(Integer) -> Enumerator<t>'
QDL.type :Enumerable, :min_by, '(Integer) { (t, t) -> Integer } -> Array<t>'
QDL.type :Enumerable, :minmax, '() -> [t, t]'
QDL.type :Enumerable, :minmax, '() { (t, t) -> Integer } -> [t, t]'
QDL.type :Enumerable, :minmax_by, '() -> [t, t]'
QDL.type :Enumerable, :minmax_by, '() { (t, t) -> Integer } -> Enumerator<t>'
QDL.type :Enumerable, :none?, '() -> %bool'
QDL.type :Enumerable, :none?, '() { (t) -> %bool } -> %bool'
QDL.type :Enumerable, :one?, '() -> %bool'
QDL.type :Enumerable, :one?, '() { (t) -> %bool } -> %bool'
QDL.type :Enumerable, :partition, '() { (t) -> %bool } -> [Array<t>, Array<t>]'
QDL.type :Enumerable, :partition, '() -> Enumerator<t>'
QDL.qdl_alias :Enumerable, :reduce, :inject
QDL.type :Enumerable, :reject, '() { (t) -> %bool } -> Array<t>'
QDL.type :Enumerable, :reject, '() -> Enumerator<t>'
QDL.type :Enumerable, :reverse_each, '() { (t) -> %any } -> Enumerator<t>' # is that really the return QDL.type? TODO args
QDL.type :Enumerable, :reverse_each, '() -> Enumerator<t>' # TODO args
QDL.qdl_alias :Enumerable, :select, :find_all
# QDL.type :Enumerable, :slice_after, '(XXXX : *XXXX)' # TODO
# QDL.type :Enumerable, :slice_before, '(XXXX : *XXXX)' # TODO
# QDL.type :Enumerable, :slice_when, '()' # TODO
QDL.type :Enumerable, :sort, '() -> Array<t>'
QDL.type :Enumerable, :sort, '() { (t, t) -> Integer } -> Array<t>'
QDL.type :Enumerable, :sort_by, '() { (t) -> %any } -> Array<t>'
QDL.type :Enumerable, :sort_by, '() -> Enumerator<t>'
QDL.type :Enumerable, :take, '(Integer n) -> Array<t> or nil'
QDL.type :Enumerable, :take_while, '() { (t) -> %bool } -> Array<t>'
QDL.type :Enumerable, :take_while, '() -> Enumerator<t>'
QDL.qdl_alias :Enumerable, :to_a, :entries
QDL.type :Enumerable, :to_h, '() -> Hash<t, t>' # TODO args?
# QDL.type :Enumerable, :zip, '(XXXX : *XXXX)' # TODO
