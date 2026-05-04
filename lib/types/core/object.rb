# Instead of qdl_nowrap, mark individual methods as not being wrapped so
# we can wrap stuff defined by the user at the top level (since those
# methods are added to Object).

# QDL.type :ARGF, ARGF
# QDL.type :ARGV, 'Array<String>'
# QDL.type :DATA, 'File'
# QDL.type :ENV, ENV
# QDL.type :FALSE, '%false'
# QDL.type :NIL, 'nil'
# QDL.type :RUBY_COPYRIGHT, 'String'
# QDL.type :RUBY_DESCRIPTION, 'String'
# QDL.type :RUBY_ENGINE, 'String'
# QDL.type :RUBY_PATCHLEVEL, Integer
# QDL.type :RUBY_PLATFORM, 'String'
# QDL.type :RUBY_RELEASE_DATE, 'String'
# QDL.type :RUBY_REVISION, Integer
# QDL.type :RUBY_VERSION, 'String'
# QDL.type :STDERR, 'IO'
# QDL.type :STDIN, 'IO'
# QDL.type :STDOUT, 'IO'
# QDL.type :TOPLEVEL_BINDING, 'Binding'
# QDL.type :TRUE, '%true'

QDL.type :Object, :!~, '(%any other) -> %bool', wrap: false
QDL.type :Object, :<=>, '(%any other) -> Integer or nil', wrap: false
QDL.type :Object, :===, '(%any other) -> %bool', wrap: false
QDL.type :Object, :==, '(%any other) -> %bool', wrap: false
## Deprecated
#QDL.type :Object, :=~, '(%any other) -> nil', wrap: false
QDL.type :Object, :class, '() -> Class', wrap: false
QDL.type :Object, :clone, '() -> self', wrap: false
# QDL.type :Object, :define_singleton_method, '(XXXX : *XXXX)') # TODO
QDL.type :Object, :display, '(IO port) -> nil', wrap: false
QDL.type :Object, :dup, '() -> self an_object', wrap: false
QDL.type :Object, :enum_for, '(?Symbol method, *%any args) -> Enumerator<%any>', wrap: false
QDL.type :Object, :enum_for, '(?Symbol method, *%any args) { (*%any args) -> %any } -> Enumerator<%any>', wrap: false
QDL.type :Object, :eql?, '(%any other) -> %bool', wrap: false
# QDL.type :Object, :extend, '(XXXX : *XXXX)') # TODO
QDL.type :Object, :freeze, '() -> self', wrap: false
QDL.type :Object, :frozen?, '() -> %bool', wrap: false
QDL.type :Object, :hash, '() -> Integer', wrap: false
QDL.type :Object, :inspect, '() -> String', wrap: false
QDL.type :Object, :instance_of?, '(Class) -> %bool', wrap: false
QDL.type :Object, :instance_variable_defined?, '(Symbol or String) -> %bool', wrap: false
QDL.type :Object, :instance_variable_get, '(Symbol or String) -> %any', wrap: false
QDL.type :Object, :instance_variable_set, '(Symbol or String, %any) -> %any', wrap: false # returns 2nd argument
QDL.type :Object, :instance_variables, '() -> Array<Symbol>', wrap: false
QDL.type :Object, :is_a?, '(Class or Module) -> %bool', wrap: false
QDL.type :Object, :kind_of?, '(Class) -> %bool', wrap: false
QDL.type :Object, :method, '(Symbol) -> Method', wrap: false
QDL.type :Object, :methods, '(?%bool regular) -> Array<Symbol>', wrap: false
QDL.type :Object, :nil?, '() -> %bool', wrap: false
QDL.type :Object, :private_methods, '(?%bool all) -> Array<Symbol>', wrap: false
QDL.type :Object, :protected_methods, '(?%bool all) -> Array<Symbol>', wrap: false
QDL.type :Object, :public_method, '(Symbol) -> Method', wrap: false
QDL.type :Object, :public_methods, '(?%bool all) -> Array<Symbol>', wrap: false
QDL.type :Object, :public_send, '(Symbol or String, *%any args) -> %any', wrap: false
QDL.type :Object, :remove_instance_variable, '(Symbol) -> %any', wrap: false
# QDL.type :Object, :respond_to?, '(Symbol or String, ?%bool include_all) -> %bool'
QDL.type :Object, :send, '(Symbol or String, *%any) -> Object', wrap: false
QDL.type :Object, :singleton_class, '() -> Class', wrap: false
QDL.type :Object, :singleton_method, '(Symbol) -> Method', wrap: false
QDL.type :Object, :singleton_methods, '(?%bool all) -> Array<Symbol>', wrap: false
QDL.type :Object, :taint, '() -> self', wrap: false
QDL.type :Object, :tainted?, '() -> %bool', wrap: false
# QDL.type :Object, :tap, '()') # TODO
QDL.type :Object, :to_enum, '(?Symbol method, *%any args) -> Enumerator<%any>', wrap: false
QDL.type :Object, :to_enum, '(?Symbol method, *%any args) {(*%any args) -> %any} -> Enumerator<%any>', wrap: false
# TODO: above alias for enum_for?
QDL.type :Object, :to_s, '() -> String', wrap: false
QDL.type :Object, :trust, '() -> self', wrap: false
QDL.type :Object, :untaint, '() -> self', wrap: false
QDL.type :Object, :untrust, '() -> self', wrap: false
QDL.type :Object, :untrusted?, '() -> %bool', wrap: false
