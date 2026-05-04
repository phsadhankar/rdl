QDL.nowrap :Encoding

QDL.type :Encoding, 'self.aliases', '() -> Hash<String, String>'
QDL.type :Encoding, 'self.compatible?', '(%any obj1, %any obj2) -> Encoding or nil'
QDL.type :Encoding, 'self.default_external', '() -> Encoding'
QDL.type :Encoding, 'self.default_external=', '(String) -> String'
QDL.type :Encoding, 'self.default_external=', '(Encoding) -> Encoding'
QDL.type :Encoding, 'self.default_internal', '() -> Encoding'
QDL.type :Encoding, 'self.default_internal=', '(String) -> String or nil'
QDL.type :Encoding, 'self.default_internal=', '(Encoding) -> Encoding or nil'
QDL.type :Encoding, 'self.find', '(String or Encoding) -> Encoding'
QDL.type :Encoding, 'self.list', '() -> Array<Encoding>'
QDL.type :Encoding, 'self.name_list', '() -> Array<String>'

QDL.type :Encoding, :ascii_compatible?, '() -> %bool'
QDL.type :Encoding, :dummy?, '() -> %bool'
QDL.type :Encoding, :inspect, '() -> String'
QDL.type :Encoding, :name, '() -> String'
QDL.type :Encoding, :names, '() -> Array<String>'
QDL.type :Encoding, :replicate, '(String name) -> Encoding'
QDL.qdl_alias :Encoding, :to_s, :name
