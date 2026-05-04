QDL.nowrap :Regexp

QDL.type :Regexp, 'self.escape', '(String or Symbol) -> String'
QDL.type :Regexp, 'self.last_match', '() -> MatchData', wrap: false # Can't wrap or messes up MatchData
QDL.type :Regexp, 'self.last_match', '(Integer) -> String', wrap: false
QDL.type :Regexp, :initialize, '(String, ?%any options, ?String kcode) -> self'
QDL.type :Regexp, :initialize, '(Regexp) -> self'
QDL.qdl_alias :Regexp, :'self.compile', :initialize
QDL.qdl_alias :Regexp, :'self.quote', :'self.escape'
QDL.type :Regexp, 'self.try_convert', '(%any obj) -> Regexp or nil'
QDL.type :Regexp, 'self.union', '(*(Regexp or String) pats) -> Regexp'
QDL.type :Regexp, 'self.union', '(Array<Regexp or String> pats) -> Regexp'
QDL.type :Regexp, :==, '(%any other) -> %bool'
QDL.type :Regexp, :===, '(%any other) -> %bool', wrap: false # Can't wrap this of it messes with $1, $2, etc as well!
QDL.type :Regexp, :=~, '(String str) -> Integer or nil', wrap: false # Can't wrap this or it will mess with $1, $2, etc
QDL.type :Regexp, :casefold?, '() -> %bool'
QDL.type :Regexp, :encoding, '() -> Encoding'
QDL.qdl_alias :Regexp, :eql?, :==
QDL.type :Regexp, :fixed_encoding?, '() -> %bool'
QDL.type :Regexp, :hash, '() -> Integer'
QDL.type :Regexp, :inspect, '() -> String'
QDL.type :Regexp, :match, '(String, ?Integer) -> MatchData or nil'
QDL.type :Regexp, :named_captures, '() -> Hash<String, Array<Integer>>'
QDL.type :Regexp, :names, '() -> Array<String>'
QDL.type :Regexp, :options, '() -> Integer'
QDL.type :Regexp, :source, '() -> String'
QDL.type :Regexp, :to_s, '() -> String'
QDL.type :Regexp, :~, '() -> Integer or nil'
