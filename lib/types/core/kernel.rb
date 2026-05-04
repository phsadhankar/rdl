QDL.nowrap :Kernel

QDL.type :Kernel, 'self.Array', '([to_ary: () -> Array<t>]) -> Array<t>'
QDL.type :Kernel, 'self.Array', "(Range<x>) -> Array<x>"
QDL.type :Kernel, 'self.Array', '([to_a: () -> Array<t>]) -> Array<t>'
QDL.type :Kernel, 'self.===', "(%any) -> %bool"
QDL.type :Kernel, 'self.Complex', '(Numeric x, Numeric y) -> Complex'
QDL.type :Kernel, 'self.Complex', '(String x) -> Complex'
QDL.type :Kernel, 'self.Float', '(Numeric x) -> Float'
# QDL.type :Kernel, 'self.Float', '(x : [to_f : () -> Float]) -> Float'
# QDL.type :Kernel, 'self.Hash', '(x : [to_hash : () -> Hash<k,v>]) -> Hash<k,v>'
QDL.type :Kernel, 'self.Hash', '(nil x) -> Hash<k,v>'
# QDL.type :Kernel, 'self.Hash, '(x : []) -> Hash<k,v>'
QDL.type :Kernel, 'self.Integer', '(Numeric or String, ?Integer) -> Integer'
# QDL.type :Kernel, 'self.Integer', '(arg : [to_int : () -> Integer], base : ?Integer) -> Integer'
# QDL.type :Kernel, 'self.Integer', '(arg : [to_i : () -> Integer], base : ?Integer) -> Integer'
QDL.type :Kernel, 'self.Rational', '(Numeric x, Numeric y) -> Rational'
QDL.type :Kernel, 'self.Rational', '(String x) -> Rational'
# QDL.type :Kernel, 'self.String', '(arg : [to_s : () -> String]) -> String'
QDL.type :Kernel, 'self.__callee__', '() -> Symbol or nil'
QDL.type :Kernel, 'self.__dir__', '() -> String or nil'
QDL.type :Kernel, 'self.__method__', '() -> Symbol or nil'
QDL.type :Kernel, 'self.`', '(String) -> String'
QDL.type :Kernel, 'self.abort', '(?String msg) -> %bot'
QDL.type :Kernel, 'self.at_exit', '() { () -> %any} -> Proc' # TODO: Fix proc
QDL.type :Kernel, 'self.autoload', '(String or Symbol module, String filename) -> nil'
QDL.type :Kernel, 'self.autoload?', '(Symbol or String name) -> String or nil'
QDL.type :Kernel, 'self.binding', '() -> Binding'
QDL.type :Kernel, 'self.block_given?', '() -> %bool'
QDL.type :Kernel, 'self.caller', '(?Integer start, ?Integer length) -> Array<String> or nil'
QDL.type :Kernel, 'self.caller', '(Range) -> Array<String> or nil'
QDL.type :Kernel, 'self.caller_locations', '(?Integer start, ?Integer length) -> Array<String> or nil'
QDL.type :Kernel, 'self.caller_locations', '(Range) -> Array<String> or nil'
QDL.type :Kernel, 'self.catch', "(x) { (?x) -> u } -> u"
 QDL.type :Kernel, 'self.dup', '() -> self'
QDL.type :Kernel, 'self.eval', '(String, ?Binding, ?String filename, ?Integer lineno) -> %any'
# QDL.type :Kernel, 'self.exec' #TODO
QDL.type :Kernel, 'self.exit', '() -> %bot'
QDL.type :Kernel, 'self.exit', '(Integer or %bool status) -> %bot'
QDL.type :Kernel, 'self.exit!', '(Integer or %bool status) -> %bot'
QDL.type :Kernel, 'self.fail', '() -> %bot'
QDL.type :Kernel, 'self.fail', '(String) -> %bot'
QDL.type :Kernel, 'self.fail', '(Class, Array<String>) -> %bot'
QDL.type :Kernel, 'self.fail', '(Class, String, ?Array<String>) -> %bot'
# QDL.type :Kernel, 'self.fail', '(String or [exception : () -> String], ?String, ?Array<String>) -> %any'
# QDL.type :Kernel, 'self.fork' #TODO
QDL.type :Kernel, 'self.format', '(String format, *%any args) -> String'
QDL.type :Kernel, 'self.gets', '(?String, ?Integer) -> String'
QDL.type :Kernel, 'self.global_variables', '() -> Array<Symbol>'
QDL.type :Kernel, 'self.instance_variable_get', '(Symbol or String) -> Object', wrap: false
QDL.type :Kernel, 'self.instance_variable_set', '(Symbol or String, %any) -> Object', wrap: false # returns 2nd argument
QDL.type :Kernel, 'self.iterator?', '() -> %bool'
# QDL.type :Kernel, 'self.lambda' # TODO
QDL.type :Kernel, 'self.kind_of?', '(Class or Module) -> %bool'
QDL.type :Kernel, 'self.load', '(String filename, ?%bool) -> %bool'
QDL.type :Kernel, 'self.local_variables', '() -> Array<Symbol>'
# QDL.type :Kernel, 'self.loop' #TODO
QDL.type :Kernel, 'self.open', '(String path, ?(String or Integer) mode, ?String perm) -> IO or nil'
# QDL.type :Kernel, 'self.open', '(String path, mode : ?String, perm: ?String) {(IO) -> %any)} -> %any' # TODO: returns block value
# QDL.type :Kernel, 'self.open', '(String path, mode : ?Integer, perm: ?String) {(IO) -> %any)} -> %any' # TODO: returns block value
# QDL.type :Kernel, 'self.p', '(*[inspect : () -> String]) -> nil'
# QDL.type :Kernel, 'self.print', '(*[to_s : () -> String] -> nil'
QDL.type :Kernel, 'self.printf', '(?IO, ?String, *%any) -> nil'
QDL.type :Kernel, :proc, '() {(*%any) -> %any} -> Proc' # TODO more precise
QDL.type :Kernel, :public_send, '(Symbol or String, *%any args) -> %any', wrap: false
QDL.type :Kernel, 'self.putc', '(Integer) -> Integer'
QDL.type :Kernel, 'self.putc', '(String) -> String'
QDL.type :Kernel, 'self.puts', '(*[to_s : () -> String]) -> nil'
QDL.type :Kernel, 'self.raise', '() -> %bot'
QDL.type :Kernel, 'raise', '() -> %bot'
# QDL.type :Kernel, 'self.raise', '(String or [exception : () -> String], ?String, ?Array<String>) -> %any'
# TODO: above same as fail?
QDL.type :Kernel, 'self.rand', '(Integer or Range<Integer> max) -> Integer'
QDL.type :Kernel, 'self.rand', '() -> Float'
QDL.type :Kernel, 'self.readline', '(?String, ?Integer) -> String'
QDL.type :Kernel, 'self.readlines', '(?String, ?Integer) -> Array<String>'
QDL.type :Kernel, 'self.require', '(String name) -> %bool'
QDL.type :Kernel, 'self.require_relative', '(String name) -> %bool'
QDL.type :Kernel, 'self.respond_to?', '(String or Symbol) -> %bool'
QDL.type :Kernel, 'self.select',
          '(Array<IO> read, ?Array<IO> write, ?Array<IO> error, ?Integer timeout) -> Array<String>' # TODO: return QDL.type?
# QDL.type :Kernel, 'self.set_trace_func' #TODO
QDL.type :Kernel, 'self.singleton_class', '() -> Class'
QDL.type :Kernel, 'self.sleep', '(Numeric duration) -> Integer'
# QDL.type :Kernel, 'self.spawn' #TODO
QDL.qdl_alias :Kernel, :'self.sprintf', :'self.format' # TODO: are they aliases?
QDL.type :Kernel, :sprintf, "(String, %any) -> String"
QDL.type :Kernel, 'self.srand', '(Numeric number) -> Integer'
QDL.type :Kernel, 'self.syscall', '(Integer num, *%any args) -> %any' # TODO : ?
# QDL.type :Kernel, 'self.system' # TODO
QDL.type :Kernel, 'self.test', '(String cmd, String file1, ?String file2) -> %bool or Time' # TODO: better, dependent QDL.type?
# QDL.type :Kernel, 'self.throw' # TODO
# QDL.type :Kernel, 'self.trace_var' # TODO
# QDL.type :Kernel, 'self.trap' # TODO
# QDL.type :Kernel, 'self.untrace_var' # TODO
QDL.type :Kernel, 'self.warn', '(*String msg) -> nil'
QDL.type :Kernel, :clone, '() -> self'
QDL.type :Kernel, :raise, '() -> %bot'
QDL.type :Kernel, :raise, '(String) -> %bot'
QDL.type :Kernel, :raise, '(Class, ?String, ?Array<String>) -> %bot'
QDL.type :Kernel, :raise, '(Exception, ?String, ?Array<String>) -> %bot'
QDL.type :Kernel, :send, '(String or Symbol, *%any) -> %any'
QDL.type :Kernel, :send, '(String or Symbol, *%any) { (*%any) -> %any } -> %any'
