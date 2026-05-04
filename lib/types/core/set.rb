QDL.nowrap :Set

QDL.type_params :Set, [:t], :all?

QDL.type :Set, 'self.[]', '(*u) -> Set<u>'
QDL.type :Set, :initialize, '(Enumerable<u> enum) -> self<u>'
QDL.type :Set, :initialize, '() -> self'

QDL.qdl_alias :Set, :&, :intersection
QDL.type :Set, :+, '(Enumerable<t> enum) -> Set<t>'
QDL.qdl_alias :Set, :-, :difference
QDL.qdl_alias :Set, :<, :proper_subset?
QDL.qdl_alias :Set, :<<, :add
QDL.qdl_alias :Set, :<=, :subset?
QDL.qdl_alias :Set, :>, :proper_superset?
QDL.qdl_alias :Set, :>=, :superset?
QDL.type :Set, :^, '(Enumerable<t> enum) -> Set<t>'
QDL.type :Set, :add, '(t o) -> self'
QDL.type :Set, :add?, '(t o) -> self or nil'
QDL.type :Set, :classify, '() { (u) -> t } -> Hash<u, Set<t>>'
QDL.type :Set, :clear, '() -> self'
QDL.qdl_alias :Set, :collect!, :map!
QDL.type :Set, :delete, '(t o) -> self'
QDL.type :Set, :delete?, '(t o) -> self or nil'
QDL.type :Set, :delete_if, '() { (t) -> %bool } -> self'
QDL.type :Set, :difference, '(Enumerable<t> enum) -> Set<t>'
QDL.type :Set, :disjoint?, '(Set<t> set) -> %bool'
#??QDL.type :Set, :divide, '() { BLOCK }'
QDL.type :Set, :each, '() { (t) -> %any } -> self'
QDL.type :Set, :each, '() -> Enumerator<t>'
QDL.type :Set, :empty?, '() -> %bool'
QDL.type :Set, :flatten!, '() -> self or nil'
QDL.post(:Set, :flatten!) { |r| (not r) || (r.none? { |x| x.is_a?(Set) }) }
QDL.type :Set, :flatten, '() -> Set'
QDL.post(:Set, :flatten) { |r| r.none? { |x| x.is_a?(Set) } }
# QDL.type :Set, :flatten_merge, '(set : XXXX, seen : ?XXXX)' #??
QDL.qdl_alias :Set, :include?, :member?
QDL.type :Set, :intersect?, '(Set<t> set) -> %bool'
QDL.type :Set, :intersection, '(Enumerable<t> enum) -> Set<t>'
QDL.type :Set, :keep_if, '() { (t) -> %bool } -> self'
QDL.qdl_alias :Set, :length, :size
QDL.type :Set, :map!, '() { (t) -> u } -> Set<u>' # !! Fix, actually changes QDL.type!
QDL.type :Set, :member?, '(t o) -> %bool'
QDL.type :Set, :merge, '(Enumerable<t> enum) -> self'
QDL.type :Set, :proper_subset?, '(Set<t> set) -> %bool'
QDL.type :Set, :proper_superset?, '(Set<t> set) -> %bool'
QDL.type :Set, :reject!, '() { (t) -> %bool } -> self or nil'
QDL.type :Set, :replace, '(Enumerable<u> enum) -> Set<u>' # !! Fix, actually changes QDL.type!
QDL.type :Set, :select!, '() { (t) -> %bool } -> self or nil'
QDL.type :Set, :size, '() -> Integer'
QDL.type :Set, :subset?, '(Set<t> set) -> %bool'
QDL.type :Set, :subtract, '(Enumerable<t> enum) -> self'
QDL.type :Set, :superset?, '(Set<t> set) -> %bool'
QDL.type :Set, :to_a, '() -> Array<t>'
#QDL.type :Set, :to_set, '(klass: ?Class, args : *XXXX) { BLOCK }' # ??
QDL.qdl_alias :Set, :|, :+
QDL.qdl_alias :Set, :union, :+
