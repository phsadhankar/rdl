QDL.nowrap :'ActiveModel::Errors'
QDL.type :'ActiveModel::Errors', :clear, '() -> %any'
QDL.type :'ActiveModel::Errors', :delete, '(%symstr) -> %any'
QDL.type :'ActiveModel::Errors', :[], '(%symstr) -> Array<String>'
QDL.type :'ActiveModel::Errors', :each, '() { (%symstr, String) -> %any } -> %any'
QDL.type :'ActiveModel::Errors', :size, '() -> Integer'
QDL.qdl_alias :'ActiveModel::Errors', :count, :size
QDL.type :'ActiveModel::Errors', :values, '() -> Array<String>'
QDL.type :'ActiveModel::Errors', :keys, '() -> Array<Symbol>'
QDL.type :'ActiveModel::Errors', :empty?, '() -> %bool'
QDL.qdl_alias :'ActiveModel::Errors', :blank?, :empty?
QDL.type :'ActiveModel::Errors', :hash, '(?%bool full_messages) -> Hash<Symbol, String>'
QDL.type :'ActiveModel::Errors', :add, '(%symstr, %symstr, ?Hash<Symbol, %any>) -> Array<String>'
QDL.type :'ActiveModel::Errors', :add, '(%symstr, { () -> String }, Hash<Symbol, %any>) -> Array<String>' # TODO: combine with prev with union once supported
