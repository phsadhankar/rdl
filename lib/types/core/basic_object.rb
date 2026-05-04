QDL.nowrap :BasicObject

QDL.type :BasicObject, :==, '(%any other) -> %bool'
QDL.type :BasicObject, :equal?, '(%any other) -> %bool'
QDL.type :BasicObject, :!, '() -> %bool'
QDL.type :BasicObject, :!=, '(%any other) -> %bool'
QDL.type :BasicObject, :instance_eval, '(String, ?String filename, ?Integer lineno) -> %any'
QDL.type :BasicObject, :instance_eval, '() { () -> %any } -> %any'
QDL.type :BasicObject, :instance_exec, '(*%any args) { (*%any) -> %any } -> %any'
QDL.type :BasicObject, :__send__, '(Symbol or String, *%any) -> %any obj'
QDL.qdl_alias :BasicObject, :__id__, :object_id
QDL.type :BasicObject, :object_id, '() -> Integer'
