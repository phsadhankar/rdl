QDL.type_params 'QDL::Type::SingletonType', [:t], :satisfies?

QDL.type 'QDL::Type::SingletonType', :initialize, "(x) -> self<x>", wrap: false
QDL.type 'QDL::Type::SingletonType', :val, "() -> t", wrap: false
QDL.type 'QDL::Type::SingletonType', :nominal, "() -> QDL::Type::NominalType", wrap: false

QDL.type 'QDL::Type::NominalType', :initialize, "(Class or String) -> self", wrap: false
QDL.type 'QDL::Type::NominalType', :klass, "() -> Class", wrap: false
QDL.type 'QDL::Type::NominalType', :name, "() -> String", wrap: false

QDL.type 'QDL::Type::GenericType', :initialize, "(QDL::Type::Type, *QDL::Type::Type) -> self", wrap: false
QDL.type 'QDL::Type::GenericType', :params, "() -> Array<QDL::Type::Type>", wrap: false
QDL.type 'QDL::Type::GenericType', :base, "() -> QDL::Type::NominalType", wrap: false

QDL.type 'QDL::Type::UnionType', :initialize, "(*QDL::Type::Type) -> self", wrap: false
QDL.type 'QDL::Type::UnionType', :canonical, "() -> QDL::Type::Type", wrap: false
QDL.type 'QDL::Type::UnionType', :types, "() -> Array<QDL::Type::Type>", wrap: false

QDL.type 'QDL::Type::TupleType', :initialize, "(*QDL::Type::Type) -> self", wrap: false
QDL.type 'QDL::Type::TupleType', :params, "() -> Array<QDL::Type::Type>", wrap: false
QDL.type 'QDL::Type::TupleType', :promote, "(?QDL::Type::Type) -> QDL::Type::GenericType", wrap: false
QDL.type 'QDL::Type::TupleType', :promote!, "(?QDL::Type::Type) -> %bool", wrap: false
QDL.type 'QDL::Type::TupleType', :check_bounds, "(?%bool) -> %bool", wrap: false

QDL.type 'QDL::Type::FiniteHashType', :elts, "() -> Hash<%any, QDL::Type::Type>", wrap: false
QDL.type 'QDL::Type::FiniteHashType', :elts=, "(Hash<%any, QDL::Type::Type>) -> Hash<%any, QDL::Type::Type>", wrap: false
QDL.type 'QDL::Type::FiniteHashType', :promote, "(?%any, ?QDL::Type::Type) -> QDL::Type::GenericType", wrap: false
QDL.type 'QDL::Type::FiniteHashType', :promote!, "(?%any, ?QDL::Type::Type) -> %bool", wrap: false
QDL.type 'QDL::Type::FiniteHashType', :initialize, "(Hash<%any, QDL::Type::Type> or {}, ?QDL::Type::Type) -> self", wrap: false
QDL.type 'QDL::Type::FiniteHashType', :check_bounds, "(?%bool) -> %bool", wrap: false

QDL.type 'QDL::Type::OptionalType', :initialize, "(QDL::Type::Type) -> self", wrap: false

QDL.type 'QDL::Type::VarargType', :initialize, '(QDL::Type::Type) -> self', wrap: false

QDL.type 'QDL::Type::VarType', :initialize, "(String) -> self", wrap: false

QDL.type "QDL::Type::Type", 'self.leq', "(QDL::Type::Type, QDL::Type::Type) -> %bool", wrap: false

QDL.type 'QDL::Globals', 'self.parser', "() -> QDL::Type::Parser", wrap: false
QDL.type 'QDL::Globals', 'self.types', "() -> Hash<Symbol, QDL::Type::Type>", wrap: false
QDL.type 'QDL::Type::Parser', :scan_str, "(String) -> QDL::Type::Type", wrap: false
QDL.type 'QDL::Config', 'self.instance', "() -> QDL::Config", wrap: false
QDL.type 'QDL::Config', 'weak_update_promote', "() -> %bool", wrap: false
QDL.type "Object", '__getobj__', "() -> self", wrap: false ## needed due to type casting
