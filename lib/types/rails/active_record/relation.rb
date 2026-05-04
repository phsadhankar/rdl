QDL.nowrap :'ActiveRecord::Relation'

QDL.type_params :'ActiveRecord::Relation', [:t], :all?

=begin
QDL.type :'ActiveRecord::Relation', :[], '(Integer) -> t'
QDL.type :'ActiveRecord::Relation', :empty?, '() -> %bool'
QDL.type :'ActiveRecord::Relation', :first, '() -> t'
QDL.type :'ActiveRecord::Relation', :length, '() -> Integer'
QDL.type :'ActiveRecord::Relation', :sort, '() {(t, t) -> Integer} -> Array<t>'
QDL.type :'ActiveRecord::Relation', :each, '() -> Enumerator<t>'
QDL.type :'ActiveRecord::Relation', :each, '() { (t) -> %any } -> Array<t>'
=end
