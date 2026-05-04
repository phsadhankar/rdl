class ActiveRecord::Base
  extend QDL::QDLAnnotate
end

module ActiveRecord::ModelSchema::ClassMethods
  extend QDL::QDLAnnotate
=begin
  qdl_post(:load_schema!) { |ret| # load_schema! doesn't return anything interesting

    columns_hash.each { |name, col|
      t = QDL::Rails.column_to_qdl(col.type)
      if col.null
        # may be null; show nullability in return type
        qdl_type name,       "() -> #{t} or nil"     # getter
        qdl_type :"#{name}=", "(#{t}) -> #{t} or nil" # setter
        qdl_type :write_attribute, "(:#{name}, #{t}) -> %bool"
        qdl_type :update_attribute, "(:#{name}, #{t}) -> %bool"
        qdl_type :update_column, "(:#{name}, #{t}) -> %bool"
      else
        # not null; can't truly check in type system but hint via the name
        qdl_type name,       "() -> !#{t}"                 # getter
        qdl_type :"#{name}=", "(!#{t}) -> !#{t}" # setter
        qdl_type :write_attribute, "(:#{name}, !#{t}) -> %bool"
        qdl_type :update_attribute, "(:#{name}, #{t}) -> %bool"
        qdl_type :update_column, "(:#{name}, #{t}) -> %bool"
      end
    }

    attribute_types = QDL::Rails.attribute_types(self)
    qdl_type :'self.find_by', '(' + attribute_types + ") -> #{self} or nil"
    qdl_type :'self.find_by!', '(' + attribute_types + ") -> #{self}"
    qdl_type :update, '(' + attribute_types + ') -> %bool'
    qdl_type :update_columns, '(' + attribute_types + ') -> %bool'
    qdl_type :'attributes=', '(' + attribute_types + ') -> %bool'

    # If called with String arguments, can't check types as precisely
    qdl_type :write_attribute, '(String, %any) -> %bool'
    qdl_type :update_attribute, '(String, %any) -> %bool'
    qdl_type :update_column, '(String, %any) -> %bool'

    qdl_type :'self.joins', "(Symbol or String) -> ActiveRecord::Associations::CollectionProxy<#{self.to_s}>"
    qdl_type :'self.none', "() -> ActiveRecord::Associations::CollectionProxy<#{self.to_s}>"
    qdl_type :'self.where', '(String, *%any) -> ActiveRecord::Associations::CollectionProxy<t>'
    qdl_type :'self.where', '(**%any) -> ActiveRecord::Associations::CollectionProxy<t>'
    true
  }
=end
end
