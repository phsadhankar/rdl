QDL.nowrap :URI

QDL.type :URI, :'self.decode_www_form', '(String, ?Encoding, ?String separator, %bool use_charset, %bool isindex) -> Array<[String,String]>'
QDL.type :URI, :'self.decode_www_form_component', '(String, ?Encoding) -> Array<[String,String]>'
# QDL.type :URI, :encode_www_form, '(Array<Array<String>>, ?) -> String' #Doublesplat
# QDL.type :URI, :encode_www_form_component, '(String, ?) -> String'
QDL.type :URI, :'self.extract', '(String, ?Array) { (*%any) -> %any} -> Array<String>'
QDL.type :URI, :'self.join', '(*String) -> URI::HTTP'
QDL.type :URI, :'self.parse', '(String) -> URI::HTTP'
QDL.type :URI, :'self.regexp', '(?Array schemes) -> Array<String>' #Assume schemes are strings
QDL.type :URI, :'self.scheme_list', '() -> Hash<String,Class>'
QDL.type :URI, :'self.split', '(String) -> Array<String or nil>'

QDL.type :URI, :'self.escape', '(String, *Regexp) -> String'
QDL.type :URI, :'self.escape', '(String, *String) -> String'
QDL.type :URI, :'self.unescape', '(*String) -> String'
QDL.qdl_alias :URI, :'self.encode', :'self.escape'
QDL.qdl_alias :URI, :'self.decode', :'self.unescape'
