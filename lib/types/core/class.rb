QDL.nowrap :Class

QDL.type :Class, :allocate, '() -> ``QDL::Type::NominalType.new(trec.val)``' # Instance of class self
QDL.type :Class, :inherited, '(Class) -> %any'
#QDL.type :Class, 'initialize', '() -> '
#QDL.type :Class, 'new', '(*%any) -> %any' #Causes two other test cases to fail
QDL.type :Class, :superclass, '() -> Class or nil'

#QDL.type :Class, :class_eval, '() {() -> %any} -> %any'
#QDL.type :Class, :method_defined?, '(String or Symbol) -> %bool'
#QDL.type :Class, :define_method, '(String or Symbol) {(*%any) -> %any} -> Proc'
QDL.type :Class, :instance_methods, '(?%bool) -> Array<Symbol>'
QDL.type :Class, :class, '() -> Class'
QDL.type :Class, :superclass, '() -> Class'
QDL.type :Class, :name, '() -> String'
QDL.type :Class, :==, '(%any) -> %bool'
QDL.type :Class, :===, '(%any) -> %bool'
