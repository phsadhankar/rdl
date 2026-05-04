QDL.nowrap :YAML
QDL.nowrap :Psych

QDL.type :YAML, 'self.load_file', '(String) -> Array<String> or Hash<Symbol, String>'
QDL.type :YAML, 'self.load', '(String) -> Array<String> or Hash<Symbol, String>'

QDL.type :Psych, 'self.load_file', '(String) -> Array<String>'
QDL.type :Psych, 'self.load', '(String) -> Array<String>'
