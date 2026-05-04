QDL.nowrap :PrettyPrint

QDL.type :PrettyPrint, 'self.format', '(?String output, ?Integer maxwidth, ?String newline) { (PrettyPrint) -> String } -> String'
QDL.type :PrettyPrint, 'self.singleline_format', '(?String output, ?Integer maxwidth, ?String newline) { (PrettyPrint) -> String } -> PrettyPrint'
QDL.type :PrettyPrint, :initialize, '(?String output, ?Integer maxwidth, ?String newline) { (PrettyPrint) -> String } -> PrettyPrint'
QDL.type :PrettyPrint, :break_outmost_groups, '() -> %bot'
QDL.type :PrettyPrint, :breakable, '(?String sep, ?Integer width) -> %bot'
QDL.type :PrettyPrint, :current_group, '() -> %any'
QDL.type :PrettyPrint, :fill_breakable, '(?String sep, ?Integer width) -> %bot'
QDL.type :PrettyPrint, :flush, '() -> %bot'
QDL.type :PrettyPrint, :group_sub, '() -> %bot'
QDL.type :PrettyPrint, :nest, '(Integer indent) { (a) -> b } -> b'
QDL.type :PrettyPrint, :text, '(String obj, ?Integer width) -> Integer'
