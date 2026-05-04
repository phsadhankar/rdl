require_relative "#{File.dirname(__FILE__)}/sql-strings.rb"

class ActiveRecord::Base
  extend QDL::Annotate

  type Object, :present?, "() -> %bool", wrap: false
  type :initialize, '(``DBType.rec_to_schema_type(trec, true)``) -> self', wrap: false
  type 'self.create', '(``DBType.rec_to_schema_type(trec, true, include_assocs: true)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type 'self.create!', '(``DBType.rec_to_schema_type(trec, true, include_assocs: true)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :initialize, '() -> self', wrap: false
  type 'self.create', '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type 'self.create!', '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :attribute_names, "() -> Array<String>", wrap: false
  type :to_json, "(?{ only: Array<String> }) -> String", wrap: false
  type :update_column, '(``uc_first_arg(trec)``, ``uc_second_arg(trec, targs)``) -> %bool', wrap: false
  type :[], '(Symbol) -> ``access_output(trec, targs)``', wrap: false
  type :save!, '(?{ validate: %bool }) -> %bool', wrap: false
  type 'self.transaction', '() {() -> u} -> u', wrap: false

  type QDL::Globals, 'self.ar_db_schema', "() -> Hash<%any, QDL::Type::GenericType>", wrap: false
  type String, :singularize, "() -> String", wrap: false
  type String, :camelize, "() -> String", wrap: false
  type String, :pluralize, "() -> String", wrap: false
  type String, :underscore, "() -> String", wrap: false

  type Object, :try, "(Symbol) -> ``try_output(trec, targs)``", wrap: false

  def Object.try_output(trec, targs)
    case trec
    when QDL::Type::SingletonType
      klass = trec.val.class
      inst = {self: trec }
    when QDL::Type::NominalType
      klass = trec.klass
      inst = {self: trec }
    when QDL::Type::GenericType
      klass = trec.base.klass
      inst = trec.to_inst.merge(self: trec)
    else
      raise "Unexpected type #{trec}."
    end
    case targs[0]
    when QDL::Type::SingletonType
      meth_types = QDL::Typecheck.lookup({}, klass.to_s, targs[0].val, nil, make_unknown: false)#QDL::Globals.info.get(klass, targs[0].val, :type)
      #meth_types = meth_types[0] if meth_types
      ret_type = meth_types ? QDL::Type::UnionType.new(*meth_types.map { |mt| mt.ret } ).canonical : QDL::Globals.types[:top]
    else
      return QDL::Globals.types[:top]
    end
  end        



  def self.access_output(trec, targs)
    case trec
    when QDL::Type::NominalType
      tname = trec.name.to_sym
      tschema = QDL.type_cast(QDL::Globals.ar_db_schema[tname].params[0], "QDL::Type::FiniteHashType", force: true).elts
      raise "Schema not found." unless tschema
      arg = targs[0]
      case arg
      when QDL::Type::SingletonType
        col = arg.val
        ret = tschema[col]
        ret = QDL::Globals.types[:nil] unless ret
        return ret
      else
        raise "TODO"
      end
    else
      raise 'unexpected type'
    end
  end
  QDL.type ActiveRecord::Base, 'self.access_output', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", wrap: false, typecheck: :type_code

  def self.uc_first_arg(trec)
    case trec
    when QDL::Type::NominalType
      tname = trec.name.to_sym
      tschema = QDL.type_cast(QDL::Globals.ar_db_schema[tname].params[0], "QDL::Type::FiniteHashType", force: true).elts
      raise "Schema not found." unless tschema
      typs = QDL.type_cast(tschema.keys, "Array<Symbol>", force: true).reject { |k| k == :__associations}.map { |k| QDL::Type::SingletonType.new(k) }
      return QDL::Type::UnionType.new(*QDL.type_cast(typs, "Array<QDL::Type::Type>"))
    else
      raise "unexpected type"
    end
  end
  QDL.type ActiveRecord::Base, 'self.uc_first_arg', "(QDL::Type::Type) -> QDL::Type::UnionType", wrap: false, typecheck: :type_code

  def self.uc_second_arg(trec, targs)
    case trec
    when QDL::Type::NominalType
      tname = trec.name.to_sym
      tschema = QDL.type_cast(QDL::Globals.ar_db_schema[tname].params[0], "QDL::Type::FiniteHashType", force: true).elts
      raise "Schema not found." unless tschema
      raise "Unexpected first arg type." unless targs[0].is_a?(QDL::Type::SingletonType) && QDL.type_cast(targs[0], "QDL::Type::SingletonType<Object>").val.is_a?(Symbol)
      return tschema[QDL.type_cast(targs[0], "QDL::Type::SingletonType<Symbol>").val]
    else
      raise "unexpected type"
    end
  end
  QDL.type ActiveRecord::Base, 'self.uc_second_arg', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", wrap: false, typecheck: :type_code


end

module ActiveRecord::AutosaveAssociation
  extend QDL::Annotate
  type :reload, "() -> %any", wrap: false
end

module ActiveRecord::Transactions
  extend QDL::Annotate
  type :destroy, '() -> self', wrap: false
  type :save, '(?{ validate: %bool }) -> %bool', wrap: false
end

module ActiveRecord::Suppressor
  extend QDL::Annotate

  type :save!, '() -> %bool', wrap: false
end

module ActiveRecord::Core::ClassMethods
  extend QDL::Annotate
  ## Types from this module are used when receiver is ActiveRecord::Base

  type :find, '(Integer or String or Symbol or Array<Integer>) -> ``DBType.find_output_type(trec, targs)``', wrap: false
  #type :find, '(Array<Integer>) -> ``DBType.find_output_type(trec, targs)``', wrap: false
  type :find, '(Integer, Integer, *Integer) -> ``DBType.find_output_type(trec, targs)``', wrap: false
  type :find_by, '(``DBType.find_input_type(trec, targs)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  ## TODO: find_by's with conditions given as string
end

module ActiveRecord::FinderMethods
  extend QDL::Annotate
  ## Types from this module are used when receiver is ActiveRecord_Relation

  type :find, '(Integer or String) -> ``DBType.find_output_type(trec, targs)``', wrap: false
  type :find, '(Array<Integer>) -> ``DBType.find_output_type(trec, targs)``', wrap: false
  type :find, '(Integer, Integer, *Integer) -> ``DBType.find_output_type(trec, targs)``', wrap: false
  type :find_by, '(``DBType.find_input_type(trec, targs)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :first, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :first!, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :first, '(Integer) -> ``DBType.rec_to_array(trec)``', wrap: false
  type :last, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :last!, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :last, '(Integer) -> ``DBType.rec_to_array(trec)``', wrap: false
  type :take, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :take!, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :take, '(Integer) -> ``DBType.rec_to_array(trec)``', wrap: false
  type :exists?, '(``DBType.exists_input_type(trec, targs)``) -> %bool', wrap: false
end

module ActiveRecord::Querying
  extend QDL::Annotate
  ## Types from this module are used when receiver is ActiveRecord::Base

  type :first, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :first!, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :first, '(Integer) -> ``DBType.rec_to_array(trec)``', wrap: false
  type :last, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :last!, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :last, '(Integer) -> ``DBType.rec_to_array(trec)``', wrap: false
  type :take, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :take!, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :take, '(Integer) -> ``DBType.rec_to_array(trec)``', wrap: false
  type :exists?, '(``DBType.exists_input_type(trec, targs)``) -> %bool', wrap: false

  type :where, '(``DBType.where_input_type(trec, targs)``) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
  type :where, '(String, *%any) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
  type :where, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord::QueryMethods::WhereChain), DBType.rec_to_nominal(trec))``', wrap: false


  type :joins, '(``DBType.joins_one_input_type(trec, targs)``) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :joins, '(``DBType.joins_multi_input_type(trec, targs)``, %any, *%any) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :group, '(*Symbol or String) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
  type :select, '(Symbol or String or Array<String>, *Symbol or String or Array<String>) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
  type :select, '() { (self) -> %bool } -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
  type :order, '(%any) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
  type :includes, '(``DBType.joins_one_input_type(trec, targs)``) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :includes, '(``DBType.joins_multi_input_type(trec, targs)``, %any, *%any) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :preload, '(``DBType.joins_one_input_type(trec, targs)``) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :preload, '(``DBType.joins_multi_input_type(trec, targs)``, %any, *%any) -> ``DBType.joins_output(trec, targs)``', wrap: false

  type :limit, '(Integer) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
  type :count, '() -> Integer', wrap: false
  type :count, '(``DBType.count_input(trec, targs)``) -> Integer', wrap: false
  type :sum, '(``DBType.count_input(trec, targs)``) -> Integer', wrap: false
  type :destroy_all, '() -> ``DBType.rec_to_array(trec)``', wrap: false
  type :delete_all, '() -> Integer', wrap: false
  type :references, '(Symbol, *Symbol) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
end

module ActiveRecord::Relation::QueryMethods
  extend QDL::Annotate
  ## Types from this module are used when receiver is ActiveRecord_relation

  type :where, '(``DBType.where_input_type(trec, targs)``) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), QDL.type_cast(trec, "QDL::Type::GenericType", force: true).params[0])``', wrap: false
  type :where, '(String, *%any) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), QDL.type_cast(trec, "QDL::Type::GenericType", force: true).params[0])``', wrap: false
  #type :where, '(String, *String) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), trec.params[0])``', wrap: false
  type :where, '() -> ``DBType.where_noarg_output_type(trec)``', wrap: false

  type :joins, '(``DBType.joins_one_input_type(trec, targs)``) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :joins, '(``DBType.joins_multi_input_type(trec, targs)``, %any, *%any) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :group, '(*Symbol or String) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), QDL.type_cast(trec, "QDL::Type::GenericType", force: true).params[0])``', wrap: false
  type :select, '(Symbol or String or Array<String>, *Symbol or String or Array<String>) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), QDL.type_cast(trec, "QDL::Type::GenericType", force: true).params[0])``', wrap: false
  type :select, '() { (``QDL.type_cast(trec, "QDL::Type::GenericType", force: true).params[0]``) -> %bool } -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), QDL.type_cast(trec, "QDL::Type::GenericType", force: true).params[0])``', wrap: false
  type :order, '(%any) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), QDL.type_cast(trec, "QDL::Type::GenericType", force: true).params[0])``', wrap: false
  type :includes, '(``DBType.joins_one_input_type(trec, targs)``) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :includes, '(``DBType.joins_multi_input_type(trec, targs)``, %any, *%any) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :preload, '(``DBType.joins_one_input_type(trec, targs)``) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :preload, '(``DBType.joins_multi_input_type(trec, targs)``, %any, *%any) -> ``DBType.joins_output(trec, targs)``', wrap: false

  type :limit, '(Integer) -> ``trec``', wrap: false
  type :references, '(Symbol, *Symbol) -> self', wrap: false
end


module ActionController::Instrumentation
  extend QDL::Annotate
=begin
  type :redirect_to, "(``redirect_input(targs)``) -> String", wrap: false

  ## When first input is a VarType, we want to associate that VarType with the first (optional) arg of redirect_to.
  ## Same goes if first input is anything *other than* a FHT.
  ## Otherwise, we drop first optional arg.
  def self.redirect_input(targs)

  end
=end
end

class ActiveRecord::QueryMethods::WhereChain
  extend QDL::Annotate
  type_params [:t], :dummy

  type :not, '(``DBType.not_input_type(trec, targs)``) -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), QDL.type_cast(trec, "QDL::Type::GenericType", force: true).params[0])``', wrap: false

end

module ActiveRecord::Delegation
  extend QDL::Annotate

  #type :+, '(%any) -> ``DBType.plus_output_type(trec, targs)``', wrap: false
  type :+, '(ActiveRecord_Relation<x>) -> ``DBType.plus_output_type(trec, targs)``', wrap: false

end

class JoinTable
  extend QDL::Annotate
  type_params [:orig, :joined], :dummy
  ## type param :orig will be nominal type of base table in join
  ## type param :joined will be a union type of all joined tables, or just a nominal type if there's only one

  ## this class is meant to only be the type parameter of ActiveRecord_Relation or WhereChain, expressing multiple joined tables instead of just a single table
end



module ActiveRecord::Scoping::Named::ClassMethods
  extend QDL::Annotate
  type :all, '() -> ``QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false

end

module ActiveRecord::Persistence
  extend QDL::Annotate
  type :update!, '(``DBType.rec_to_schema_type(trec, true)``) -> %bool', wrap: false
  type :update, '(``DBType.rec_to_schema_type(trec, true)``) -> %bool', wrap: false
  type :update_attribute, '(Symbol, ``DBType.update_attribute_input(trec, targs)``) -> %bool', wrap: false
end

module ActiveRecord::Calculations
  extend QDL::Annotate
  type :count, '() -> Integer', wrap: false
  type :count, '(``DBType.count_input(trec, targs)``) -> Integer', wrap: false
  type :sum, '(``DBType.count_input(trec, targs)``) -> Integer', wrap: false
end

class ActiveRecord_Relation
  ## In practice, this is actually a private class nested within
  ## each ActiveRecord::Base, e.g. Person::ActiveRecord_Relation.
  ## Using this class just for type checking.
  extend QDL::Annotate
  include ActiveRecord::Relation::QueryMethods
  include ActiveRecord::FinderMethods
  include ActiveRecord::Calculations
  include ActiveRecord::Delegation

  type_params [:t], :dummy

  type :each, '() -> ``DBType.each_no_block_ret(trec)``', wrap: false
  type :each, '() { (``DBType.each_block_arg(trec)``) -> %any } -> Array<t>', wrap: false
  type :empty?, '() -> %bool', wrap: false
  type :present?, '() -> %bool', wrap: false
  type :create, '(``DBType.rec_to_schema_type(trec, true, include_assocs: true)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :create, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :create!, '(``DBType.rec_to_schema_type(trec, true, include_assocs: true)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :create!, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :new, '(``DBType.rec_to_schema_type(trec, true)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :new, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :build, '(``DBType.rec_to_schema_type(trec, true)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :build, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :destroy_all, '() -> ``DBType.rec_to_array(trec)``', wrap: false
  type :delete_all, '() -> Integer', wrap: false
  type :map, '() { (t) -> u } -> Array<u>'
  type :all, '() -> self', wrap: false ### kind of a silly method, always just returns self
  type :collect, "() { (t) -> u } -> Array<u>", wrap: false
  type :find_each, "() { (t) -> x } -> nil", wrap: false
  type :to_a, "() -> ``DBType.rec_to_array(trec)``", wrap: false
  type :[], "(Integer) -> t", wrap: false
  type :size, "() -> Integer", wrap: false
  type :update_all, '(``QDL::Type::UnionType.new(QDL::Globals.types[:string], DBType.rec_to_schema_type(trec, true))``) -> Integer', wrap: false
  type :valid, "() -> self", wrap: false
  type :sort, "() { (t, t) -> Integer } -> Array<t>", wrap: false
end




class DBType
  ## given a type (usually representing a receiver type in a method call), this method returns the nominal type version of that type.
  ## if the given type represents a joined table, then we return the nominal type version of the *base* of the joined table.
  ## [+ t +] is the type for which we want the nominal type.
  def self.rec_to_nominal(t)
    case t
    when QDL::Type::SingletonType
      val = QDL.type_cast(t.val, "Class", force: true)
      raise QDL::Typecheck::StaticTypeError, "Expected class singleton type, got #{val} instead." unless val.is_a?(Class)
      return QDL::Type::NominalType.new(val)
    when QDL::Type::GenericType
      raise QDL::Typecheck::StaticTypeError, "got unexpected type #{t}" unless t.base.klass == ActiveRecord_Relation
      param = t.params[0]
      case param
      when QDL::Type::GenericType
        ## should be JoinTable
        ## When getting an indivual record from a join table, record will be of type of the base table in the join
        raise QDL::Typecheck::StaticTypeError, "got unexpected type #{param}" unless param.base.klass == JoinTable
        return param.params[0]
      when QDL::Type::NominalType
        return param
      else
        raise QDL::Typecheck::StaticTypeError, "got unexpected type #{t.params[0]}"
      end
    end
  end
  QDL.type DBType, 'self.rec_to_nominal', "(QDL::Type::Type) -> QDL::Type::Type", wrap: false, typecheck: :type_code

  def self.rec_to_array(trec)
    QDL::Type::GenericType.new(QDL::Globals.types[:array], rec_to_nominal(trec))
  end
    QDL.type DBType, 'self.rec_to_array', "(QDL::Type::Type) -> QDL::Type::GenericType", wrap: false, typecheck: :type_code

  ## given a receiver type in various kinds of query calls, returns the accepted finite hash type input,
  ## or a union of types if the receiver represents joined tables.
  ## [+ trec +] is the type of the receiver in the method call.
  ## [+ check_col +] is a boolean indicating whether or not the column types (i.e., values in the finite hash type) will be checked.
  ## [+ include_assocs +] is a bool indicating whether or not to include associations in returned hash, e.g., for `create` method.
  def self.rec_to_schema_type(trec, check_col, takes_array=false, include_assocs: false)
    case trec
    when QDL::Type::GenericType
      raise "Unexpected type #{trec}." unless (trec.base.klass == ActiveRecord_Relation) || (trec.base.klass == ActiveRecord::QueryMethods::WhereChain)
      param = trec.params[0]
      case param
      when QDL::Type::GenericType
        ## should be JoinTable
        raise "1. rec_to_schema unexpected type #{trec}" unless param.base.klass == JoinTable
        base_name = QDL.type_cast(param.params[0], "QDL::Type::NominalType", force: true).klass.to_s.singularize.to_sym ### singularized symbol name of first param in JoinTable, which is base table of the joins
        type_hash = table_name_to_schema_type(base_name, check_col, takes_array, include_assocs: include_assocs).elts
        pp1 = param.params[1]
        case pp1
        when QDL::Type::NominalType
          ## just one table joined to base table
          joined_name = pp1.klass.to_s.singularize.to_sym
          joined_type = QDL::Type::OptionalType.new(table_name_to_schema_type(joined_name, check_col, takes_array, include_assocs: include_assocs))
          type_hash = type_hash.merge({ joined_name.to_s.pluralize.underscore.to_sym => joined_type })
        when QDL::Type::UnionType
          ## multiple tables joined to base table
          joined_hash = QDL.type_cast(Hash[pp1.types.map { |t|
                               joined_name = QDL.type_cast(t, "QDL::Type::NominalType", force: true).klass.to_s.singularize.to_sym
                               joined_type = QDL::Type::OptionalType.new(table_name_to_schema_type(joined_name, check_col, takes_array, include_assocs: include_assocs))
                               [joined_name.to_s.pluralize.underscore.to_sym, joined_type]
                             }
                                          ], "Hash<Symbol, QDL::Type::FiniteHashType>", force: true)
          type_hash = type_hash.merge(joined_hash)
        else
          raise "2. rec_to_schema unexpected type #{trec}"
        end
        return QDL::Type::FiniteHashType.new(type_hash, nil)
      when QDL::Type::NominalType
        tname = param.klass.to_s.to_sym
        return table_name_to_schema_type(tname, check_col, takes_array, include_assocs: include_assocs)
      else
        raise QDL::Typecheck::StaticTypeError, "Unexpected type parameter in  #{trec}."
      end
    when QDL::Type::SingletonType
      val = QDL.type_cast(trec.val, 'Class', force: true)
      raise QDL::Typecheck::StaticTypeError, "Unexpected receiver type #{trec}." unless val.is_a?(Class)
      tname = val.to_s.to_sym
      return table_name_to_schema_type(tname, check_col, takes_array, include_assocs: include_assocs)
    when QDL::Type::NominalType
      tname = trec.name.to_sym
      return table_name_to_schema_type(tname, check_col, takes_array, include_assocs: include_assocs)
    else
      raise QDL::Typecheck::StaticTypeError, "Unexpected receiver type #{trec}."
    end
  end
  QDL.type DBType, 'self.rec_to_schema_type', "(QDL::Type::Type, %bool, ?%bool) -> QDL::Type::FiniteHashType", wrap: false, typecheck: :type_code

  ## turns a given table name into the appropriate finite hash type based on table schema, with optional or top-type values
  ## [+ tname +] is the table name as a symbol
  ## [+ check_col +] is a boolean indicating whether or not column types will eventually be checked
  def self.table_name_to_schema_type(tname, check_col, takes_array=false, include_assocs: false)
    #h = QDL.type_cast({}, "Hash<%any, QDL::Type::Type>", force: true)
    ttype = QDL::Globals.ar_db_schema[tname]
    raise QDL::Typecheck::StaticTypeError, "No table type for #{tname} found." unless ttype
    tschema = QDL.type_cast(ttype.params[0], "QDL::Type::FiniteHashType", force: true).elts.except(:__associations)
    h = Hash[tschema.map { |k, v|
               if check_col
                 v = QDL::Type::UnionType.new(v, QDL::Globals.types[:symbol]) if v == QDL::Globals.types[:string] ## ran into cases where symbols can be accepted in addition to string values.
                 v = QDL::Type::UnionType.new(v, QDL::Type::GenericType.new(QDL::Globals.types[:array], v)).canonical if takes_array
                 [k, QDL::Type::OptionalType.new(v)]
               else
                 [k, QDL::Type::OptionalType.new(QDL::Globals.types[:top])]
               end
             }]
    if include_assocs
      ## include associations in schema hash
      table_class = Object.const_get(tname)
      assoc_hash = {}
      table_class.reflect_on_all_associations.each { |a|
        if check_col
          assoc_type = QDL::Type::NominalType.new(a.class_name)
          if a.name.to_s == a.plural_name
            ## association is plural
            assoc_hash[a.name] = QDL::Type::OptionalType.new(QDL::Type::GenericType.new(QDL::Globals.types[:array], assoc_type))
          else
            assoc_hash[a.name] = QDL::Type::OptionalType.new(assoc_type)
          end
        else
          assoc_hash[a.name] = QDL::Type::OptionalType.new(QDL::Globals.types[:top])
        end
      }
      h.merge!(assoc_hash)
    end
    QDL::Type::FiniteHashType.new(QDL.type_cast(h, "Hash<%any, QDL::Type::Type>", force: true), nil)
  end
  QDL.type DBType, 'self.table_name_to_schema_type', "(Symbol, %bool, ?%bool) -> QDL::Type::FiniteHashType", wrap: false, typecheck: :type_code

  def self.where_input_type(trec, targs)
    handle_sql_strings(trec, targs) if targs[0].is_a?(QDL::Type::PreciseStringType) && !targs[1].nil? && !targs[1].kind_of_var_input?
    tschema = rec_to_schema_type(trec, true, true)
    return QDL::Type::UnionType.new(tschema, QDL::Globals.types[:string], QDL::Globals.types[:array]) ## no indepth checking for string or array cases
  end
  QDL.type Object, 'self.handle_sql_strings', "(QDL::Type::Type, Array<QDL::Type::Type>) -> %any", wrap: false
  QDL.type DBType, 'self.where_input_type', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::UnionType", wrap: false, typecheck: :type_code

  def self.find_input_type(trec, targs)
    handle_sql_strings(trec, targs) if targs[0].is_a? QDL::Type::PreciseStringType
    rec_to_schema_type(trec, true)
  end

  def self.update_attribute_input(trec, targs)
    col = targs[0].val
    col_type = targs[1]
    schema = DBType.rec_to_schema_type(trec, true)
    schema.elts[col]
  end

  def self.where_noarg_output_type(trec)
    case trec
    when QDL::Type::SingletonType
      ## where called directly on class
      QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord::QueryMethods::WhereChain), rec_to_nominal(trec))
    when QDL::Type::GenericType
    ## where called on ActiveRecord_Relation
      raise QDL::Typecheck::StaticTypeError, "Unexpected receiver type #{trec}." unless trec.base.klass == ActiveRecord_Relation
      return QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord::QueryMethods::WhereChain), trec.params[0])
    else
      raise QDL::Typecheck::StaticTypeError, "Unexpected receiver type #{trec}."
    end
  end
    QDL.type DBType, 'self.where_noarg_output_type', "(QDL::Type::Type) -> QDL::Type::GenericType", wrap: false, typecheck: :type_code

  def self.not_input_type(trec, targs)
    tschema = rec_to_schema_type(trec, true)
    return QDL::Type::UnionType.new(tschema, QDL::Globals.types[:string], QDL::Globals.types[:array]) ## no indepth checking for string or array cases
  end
  QDL.type DBType, 'self.not_input_type', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::UnionType", wrap: false, typecheck: :type_code

  def self.exists_input_type(trec, targs)
    raise "Unexpected number of arguments to ActiveRecord::Base#exists?." unless targs.size <= 1
    case targs[0]
    when QDL::Type::FiniteHashType
      typ =  rec_to_schema_type(trec, false)
    else
      ## any type can be accepted, only thing we're intersted in is when a hash is given
      ## TODO: what if we get a nominal Hash type?
      typ = targs[0]
    end
    return QDL::Type::OptionalType.new(QDL::Type::UnionType.new(QDL::Globals.types[:integer], QDL::Globals.types[:string], typ))
  end
  QDL.type DBType, 'self.exists_input_type', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", wrap: false, typecheck: :type_code


  def self.find_output_type(trec, targs)
    case targs.size
    when 0
      raise QDL::Typecheck::StaticTypeError, "No arguments given to ActiveRecord::Base#find."
    when 1
      arg0 = targs[0]
      case arg0
      when QDL::Globals.types[:integer], QDL::Globals.types[:string], QDL::Globals.types[:symbol]
        DBType.rec_to_nominal(trec)
      when QDL::Type::SingletonType
      # expecting symbol or integer here
        case arg0.val
        when Integer
          DBType.rec_to_nominal(trec)
        when Symbol
        ## TODO
        ## Actually, this is deprecated in later versions
          raise QDL::Typecheck::StaticTypeError, "Unexpected arg type #{arg0} in call to ActiveRecord::Base#find."
p        else
          raise QDL::Typecheck::StaticTypeError, "Unexpected arg type #{arg0} in call to ActiveRecord::Base#find."
        end
      when QDL::Type::GenericType, QDL::Type::TupleType
        QDL::Type::GenericType.new(QDL::Globals.types[:array], DBType.rec_to_nominal(trec))
      when QDL::Type::VarType
        nom = DBType.rec_to_nominal(trec)
        QDL::Type::UnionType.new(QDL::Type::GenericType.new(QDL::Globals.types[:array], nom), nom)
      else
        raise QDL::Typecheck::StaticTypeError, "Unexpected arg type #{arg0} in call to ActiveRecord::Base#find."
      end
    else
      DBType.rec_to_nominal(trec)
    end
  end
  QDL.type DBType, 'self.find_output_type', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", wrap: false, typecheck: :type_code

  def self.joins_one_input_type(trec, targs)
    return QDL::Globals.types[:top] unless targs.size == 1 ## trivial case, won't be matched
    case trec
    when QDL::Type::SingletonType
      base_klass = QDL.type_cast(trec, "QDL::Type::SingletonType<Symbol>").val
    when QDL::Type::GenericType
      raise "Unexpected type #{trec}." unless (QDL.type_cast(trec, "QDL::Type::GenericType").base.klass == ActiveRecord_Relation)
      param = QDL.type_cast(trec, "QDL::Type::GenericType").params[0]
      case param
      when QDL::Type::GenericType
        raise "Unexpected type #{trec}." unless (param.base.klass == JoinTable)
        base_klass = QDL.type_cast(param.params[0], "QDL::Type::NominalType", force: true).klass
      when QDL::Type::NominalType
        base_klass = param.klass
      else
        raise "unexpected parameter type in #{trec}"
      end
    else
      raise "unexpected receiver type #{trec}"
    end
    arg0 = targs[0]
    case arg0
    when QDL::Type::SingletonType
      sym = QDL.type_cast(arg0, "QDL::Type::SingletonType<Symbol>").val
      raise QDL::Typecheck::StaticTypeError, "Unexpected arg type #{trec} in call to joins." unless sym.is_a?(Symbol)
      raise QDL::Typecheck::StaticTypeError, "#{trec} has no association to #{arg0}, cannot perform joins." unless associated_with?(QDL.type_cast(base_klass, "Symbol", force: true), sym)
      return arg0
    when QDL::Type::FiniteHashType
      QDL.type_cast(QDL.type_cast(arg0, "QDL::Type::FiniteHashType").elts, "Hash<Symbol, QDL::Type::Type>", force: true).each { |key, val|
        raise QDL::Typecheck::StaticTypeError, "Unexpected hash arg type #{arg0} in call to joins." unless key.is_a?(Symbol) && val.is_a?(QDL::Type::SingletonType) && QDL.type_cast(val, "QDL::Type::SingletonType<Object>").val.is_a?(Symbol)
        val_sym = QDL.type_cast(val, "QDL::Type::SingletonType<Symbol>").val
        raise QDL::Typecheck::StaticTypeError, "#{trec} has no association to #{key}, cannot perform joins." unless associated_with?(QDL.type_cast(base_klass, "Symbol", force: true), key)
        key_klass = key.to_s.singularize.camelize
        raise QDL::Typecheck::StaticTypeError, "#{key} has no association to #{val_sym}, cannot perform joins." unless associated_with?(key_klass, val_sym)
      }
      return arg0
    else
      raise QDL::Typecheck::StaticTypeError, "Unexpected arg type #{arg0} in call to joins."
    end
  end
  QDL.type DBType, 'self.joins_one_input_type', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", wrap: false, typecheck: :type_code

  def self.joins_multi_input_type(trec, targs)
    return QDL::Globals.types[:top] unless targs.size > 1 ## trivial case, won't be matched
    targs.each { |arg|
      joins_one_input_type(trec, [arg])
    }
    return targs[0] ## since this method is called as first argument in type
  end
  QDL.type DBType, 'self.joins_multi_input_type', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", wrap: false, typecheck: :type_code

  def self.associated_with?(rec, sym)
    tschema = QDL::Globals.ar_db_schema[rec.to_s.to_sym]
    raise QDL::Typecheck::StaticTypeError, "No table type for #{rec} found." unless tschema
    schema = QDL.type_cast(tschema.params[0], "QDL::Type::FiniteHashType", force: true).elts
    assoc = schema[:__associations]
    raise QDL::Typecheck::StaticTypeError, "Table #{rec} has no associations, cannot perform joins." unless assoc
    QDL.type_cast(QDL.type_cast(assoc, "QDL::Type::FiniteHashType").elts, "Hash<Symbol, QDL::Type::Type>", force: true).each { |key, value|
      case value
      when QDL::Type::SingletonType
        return true if QDL.type_cast(value.val, "Object", force: true) == sym ## no need to change any plurality here
      when QDL::Type::UnionType
        ## for when rec has multiple of the same kind of association
        value.types.each { |t|
          raise "Unexpected type #{t}." unless t.is_a?(QDL::Type::SingletonType) && (QDL.type_cast(t, "QDL::Type::SingletonType<Object>").val.class == Symbol)
          return true if QDL.type_cast(t, "QDL::Type::SingletonType<Symbol>").val == sym
        }
      else
        raise QDL::Typecheck::StaticTypeError, "Unexpected association type #{value}"
      end
    }
    return false
  end
    QDL.type DBType, 'self.associated_with?', "(Class or Symbol or String, Symbol) -> %bool", wrap: false, typecheck: :type_code

  def self.get_joined_args(targs)
    arg_types = QDL.type_cast([], "Array<QDL::Type::Type>", force: true)
    targs.each { |arg|
    case arg
    when QDL::Type::SingletonType
      raise QDL::Typecheck::StaticTypeError, "Unexpected joins arg type #{arg}" unless (QDL.type_cast(arg.val, "Object", force: true).class == Symbol)
      arg_types = arg_types + [QDL::Type::NominalType.new(QDL.type_cast(arg.val, "Symbol", force: true).to_s.singularize.camelize)]
    when QDL::Type::FiniteHashType
      hsh = arg.elts
      #raise "got #{hsh} but it's not supported" unless hsh.size == 1
      hsh.each { |key, val| 
        #key, val = QDL.type_cast(hsh.first, "[Symbol, QDL::Type::SingletonType<Symbol>]", force: true)
        val = val.val
        arg_types = arg_types + [QDL::Type::UnionType.new(QDL::Type::NominalType.new(key.to_s.singularize.camelize), QDL::Type::NominalType.new(val.to_s.singularize.camelize))]
      }
    else
      raise "Unexpected arg type #{arg} to joins."
    end
    }
    if arg_types.size > 1
      return QDL::Type::UnionType.new(*arg_types)
    elsif arg_types.size == 1
      return arg_types[0]
    else
      raise "oops, didn't expect to get here."
    end
  end
    QDL.type DBType, 'self.get_joined_args', "(Array<QDL::Type::Type>) -> QDL::Type::Type", wrap: false, typecheck: :type_code

  def self.joins_output(trec, targs)
    arg_type = get_joined_args(targs)
    case trec
    when QDL::Type::SingletonType
      joined = arg_type
    when QDL::Type::GenericType
      raise "Unexpected type #{trec}." unless (trec.base.klass == ActiveRecord_Relation)
      param = trec.params[0]
      case param
      when QDL::Type::GenericType
        raise "Unexpected type #{trec}." unless (param.base.klass == JoinTable)
        joined = QDL::Type::UnionType.new(param.params[1], arg_type)
      when QDL::Type::NominalType
        joined = arg_type
      else
        raise "unexpected parameter type in #{trec}"
      end
    else
      raise "joins_output unexpected type #{trec}"
    end
    jt = QDL::Type::GenericType.new(QDL::Type::NominalType.new(JoinTable), rec_to_nominal(trec), joined)
    ret = QDL::Type::GenericType.new(QDL::Type::NominalType.new(ActiveRecord_Relation), jt)
    return ret
  end
  QDL.type DBType, 'self.joins_output', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", wrap: false, typecheck: :type_code

    def self.plus_output_type(trec, targs)
    typs = QDL.type_cast([], "Array<QDL::Type::Type>", force: true)
    [trec, targs[0]].each { |t|
      case t
      when QDL::Type::GenericType
        raise "Expected ActiveRecord_Relation or Array, got #{t} for #{trec} and #{targs}." unless (t.base.name == "ActiveRecord_Relation") or (t.base.name == "Array")
        param0 = t.params[0]
        case param0
        when QDL::Type::GenericType
          raise "Unexpected paramter type in #{t}." unless param0.base.name == "JoinTable"
          typs = typs + [param0.params[0]] ## base of join table
          typs = typs + [param0.params[1]] ## joined tables
        when QDL::Type::NominalType
          typs = typs + [param0]
        else
          raise "unexpected paramater type in #{t}"
        end
      when QDL::Type::VarType
        return QDL::Globals.types[:array]
      else
        #raise "plus unexpected type #{t} with #{trec} and #{targs[0]}"
        return QDL::Globals.types[:bot]
      end
    }
    QDL::Type::GenericType.new(QDL::Type::NominalType.new(Array), QDL::Type::UnionType.new(*typs))
    end
    QDL.type DBType, 'self.plus_output_type', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::GenericType", wrap: false, typecheck: :type_code

    def self.count_input(trec, targs)
      hash_type = rec_to_schema_type(trec, true)## Bug found here. orginally had: rec_to_schema_type(trec, targs).elts
      typs = QDL.type_cast([], "Array<QDL::Type::Type>", force: true)
      hash_type.elts.each { |k, v| ## bug here, originally had: hash_type.each { |k, v|
        if v.is_a?(QDL::Type::FiniteHashType)
          ## will reach this with joined tables, but we're only interested in column names
          QDL.type_cast(v, 'QDL::Type::FiniteHashType', force: true).elts.each { |k1, v1|
            typs = typs + [QDL::Type::SingletonType.new(k1)] unless v1.is_a?(QDL::Type::FiniteHashType) ## potentially two dimensions in joined table
          }
        else
          typs = typs + [QDL::Type::SingletonType.new(k)]
        end
      }
      return QDL::Type::OptionalType.new(QDL::Type::UnionType.new(*typs))
    end
    QDL.type DBType, 'self.count_input', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::OptionalType", wrap: false, typecheck: :type_code


  def self.each_block_arg(trec)
    case trec.params[0]
    when QDL::Type::GenericType
      raise "Expected JoinTable" unless trec.params[0].base.klass == JoinTable
      return trec.params[0].params[0]
    else
      return trec.params[0]
    end
  end

  def self.each_no_block_ret(trec)
    QDL::Type::GenericType.new(QDL::Type::NominalType.new(Enumerator), each_block_arg(trec))
  end
    
end

