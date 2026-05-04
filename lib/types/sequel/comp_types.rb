class SequelDB
  extend QDL::Annotate

  type 'self.[]', '(Symbol) -> ``gen_output_type(targs[0])``', wrap: false
  type '[]', '(Symbol) -> ``gen_output_type(targs[0])``', wrap: false
  type :transaction, "() { () -> %any } -> self", wrap: false


  type QDL::Globals, 'self.seq_db_schema', "()-> Hash<Symbol, QDL::Type::FiniteHashType>", wrap: false

  def self.gen_output_type(targ)
    case targ
    when QDL::Type::SingletonType
      t = QDL::Globals.seq_db_schema[QDL.type_cast(targ.val, "Symbol", force: true)]
      raise "no schema for table #{targ}" if t.nil?
      new_t = t.elts.clone.merge({__selected: QDL::Globals.types[:nil], __last_joined: targ, __all_joined: targ, __orm: QDL::Globals.types[:false] })
      new_fht = QDL::Type::FiniteHashType.new(new_t, nil)
      return QDL::Type::GenericType.new(QDL::Type::NominalType.new(Table), new_fht)
    else
      raise "unexpected type"
    end
  end

  QDL.type SequelDB, 'self.gen_output_type', "(QDL::Type::Type) -> QDL::Type::GenericType", typecheck: :type_code, wrap: false
end

module Sequel::Mysql2; end

class Sequel::Mysql2::Database
  extend QDL::Annotate
  ## This class is identical to SequelDB (above), except its name.
  ## Necessary to support different apps.

  type 'self.[]', '(Symbol) -> ``gen_output_type(targs[0])``', wrap: false
  type '[]', '(Symbol) -> ``gen_output_type(targs[0])``', wrap: false
  type :transaction, "() { () -> %any } -> self", wrap: false


  type QDL::Globals, 'self.seq_db_schema', "()-> Hash<Symbol, QDL::Type::FiniteHashType>", wrap: false

  def self.gen_output_type(targ)
    case targ
    when QDL::Type::SingletonType
      t = QDL::Globals.seq_db_schema[QDL.type_cast(targ.val, "Symbol", force: true)]
      raise "no schema for table #{targ}" if t.nil?
      new_t = t.elts.clone.merge({__selected: QDL::Globals.types[:nil], __last_joined: targ, __all_joined: targ, __orm: QDL::Globals.types[:false] })
      new_fht = QDL::Type::FiniteHashType.new(new_t, nil)
      return QDL::Type::GenericType.new(QDL::Type::NominalType.new(Table), new_fht)
    else
      raise "unexpected type #{targ.class}"
    end
  end
  QDL.type Sequel::Mysql2::Database, 'self.gen_output_type', "(QDL::Type::Type) -> QDL::Type::GenericType", typecheck: :type_code, wrap: false

end


module Sequel
  extend QDL::Annotate

  type 'self.sqlite', '() -> DBVal', wrap: false

  type 'self.[]', '(Symbol) -> ``gen_output_type(targs[0])``', wrap: false
  type 'self.qualify', '(Symbol, Symbol) -> ``qualify_output_type(targs)``', wrap: false

  def self.gen_output_type(targ)
    case targ
    when QDL::Type::SingletonType
      QDL::Type::GenericType.new(QDL::Type::NominalType.new(SeqIdent), targ)
    else
      raise "unexpected type"
    end
  end
  QDL.type Sequel, 'self.gen_output_type', "(QDL::Type::Type) -> QDL::Type::GenericType", typecheck: :type_code, wrap: false

  def self.qualify_output_type(targs)
    raise "unexpected types" unless targs.all? { |a| a.is_a?(QDL::Type::SingletonType) }
    QDL::Type::GenericType.new(QDL::Type::NominalType.new(SeqQualIdent), targs[0], targs[1])
  end
  QDL.type Sequel, 'self.qualify_output_type', "(Array<QDL::Type::Type>) -> QDL::Type::GenericType", typecheck: :type_code, wrap: false
end
class SeqIdent
  extend QDL::Annotate
  type_params [:t], :all?
  type :[], '(Symbol) -> ``gen_output_type(trec, targs[0])``', wrap: false

  def self.gen_output_type(trec, targ)
    case trec
    when QDL::Type::GenericType
      param = trec.params[0]
      case targ
      when QDL::Type::SingletonType
        return QDL::Type::GenericType.new(QDL::Type::NominalType.new(SeqQualIdent), param, targ)
      else
        raise "expected singleton"
      end
    else
      raise "unexpected trec type"
    end
  end
  QDL.type SeqIdent, 'self.gen_output_type', "(QDL::Type::Type, QDL::Type::Type) -> QDL::Type::GenericType", typecheck: :type_code, wrap: false

end

class SeqQualIdent
  extend QDL::Annotate
  type_params [:table, :column], :all?

end

class Table
  extend QDL::Annotate
  type_params [:t], :all?

  type :join, "(Symbol, %any) -> ``join_ret_type(trec, targs)``", wrap: false
  type :join, "(Symbol, %any, %any) -> ``join_ret_type(trec, targs)``", wrap: false

  QDL.qdl_alias :Table, :inner_join, :join
  QDL.qdl_alias :Table, :left_join, :join
  QDL.qdl_alias :Table, :left_outer_join, :join

  def self.get_schema(hash)
    hash.select { |key, val| ![:__last_joined, :__all_joined, :__selected, :__orm].member?(key) }
  end
  QDL.type Table, 'self.get_schema', "(Hash<%any, QDL::Type::Type>) -> Hash<%any, QDL::Type::Type>", typecheck: :type_code, wrap: false

  def self.get_all_joined(t)
    case t
    when QDL::Type::SingletonType
      sing = QDL.type_cast(t, "QDL::Type::SingletonType<Symbol>", force: true)
      raise "unexpected type #{t} in __all_joined clause" unless sing.val.is_a?(Symbol)
      return [sing.val]
    when QDL::Type::UnionType
      all = t.types.map { |subt|
        raise "unexpected type #{subt} in union type within __all_joined clause" unless subt.is_a?(QDL::Type::SingletonType) && QDL.type_cast(subt, "QDL::Type::SingletonType<Symbol>", force: true).val.is_a?(Symbol)
        QDL.type_cast(subt, "QDL::Type::SingletonType<Symbol>", force: true).val
      }
      return all
    when nil
      return QDL.type_cast([], "Array<Symbol>", force: true)
    else
      raise "unexpected type #{t} in __all_joined clause"
    end
  end
  QDL.type Table, 'self.get_all_joined', "(QDL::Type::Type) -> Array<Symbol>", typecheck: :type_code, wrap: false

  def self.join_ret_type(trec, targs)
    raise QDL::Typecheck::StaticTypeError, "Unexpected number of arguments to `join`." unless targs.size == 2
    targ1, targ2 = *targs
    raise QDL::Typecheck::StaticTypeError, "Unexpected second argument type #{targ2} to `join`." unless targ2.is_a?(QDL::Type::FiniteHashType)
    arg_join_column = QDL.type_cast(QDL.type_cast(targ2, "QDL::Type::FiniteHashType").elts.keys[0], "Symbol", force: true) ## column name of arg table which is joined on
    rec_join_column = QDL.type_cast(QDL.type_cast(targ2, "QDL::Type::FiniteHashType").elts[arg_join_column], "Symbol", force: true) ## column name of receiver table which is joined on
    case trec
    when QDL::Type::GenericType
      raise QDL::Typecheck::StaticTypeError, "unexpceted generic type in call to join" unless trec.base.name == "Table"
      receiver_param = QDL.type_cast(trec.params[0], "QDL::Type::FiniteHashType", force: true).elts
      receiver_schema = get_schema(receiver_param)
      join_source_schema = get_schema(QDL::Globals.seq_db_schema[QDL.type_cast(receiver_param[:__last_joined], "QDL::Type::SingletonType<Symbol>", force: true).val].elts)
      rec_all_joined = get_all_joined(receiver_param[:__all_joined])

      case rec_join_column
      when QDL::Type::SingletonType
        ## given symbol for second column to join on
        if rec_join_column.to_s.include?("__")
          ## qualified column name in old versions of sequel.
          check_qual_column(rec_join_column, rec_all_joined)
        else
          raise QDL::Typecheck::StaticTypeError, "No column #{rec_join_column} for receiver in call to `join`." if join_source_schema[rec_join_column.val].nil?
        end
      when QDL::Type::GenericType
      ## given qualified column, e.g. Sequel[:people][:name]
        raise QDL::Typecheck::StaticTypeError, "unexpected generic type #{rec_join_column}" unless rec_join_column.base.name == "SeqQualIdent"
        qual_table, qual_column = rec_join_column.params.map { |t| t.val }
        raise QDL::Typecheck::StaticTypeError, "qualified table #{qual_table} is not joined in receiver table, and so its columns cannot be joined on" unless rec_all_joined.include?(qual_table)
        qual_table_schema = get_schema(QDL::Globals.seq_db_schema[qual_table].elts)
        raise QDL::Typecheck::StaticTypeError, "No column #{qual_column} in table #{qual_table}." if qual_table_schema[qual_column].nil?
      else
        raise "Unexpected column #{rec_join_column} of class #{rec_join_column.class} to join on"
      end
      case targ1
      when QDL::Type::SingletonType
        val = QDL.type_cast(targ1.val, "Symbol", force: true)
        raise QDL::Typecheck::StaticTypeError, "Expected Symbol for first argument to `join`." unless val.is_a?(Symbol)
        table_name = val
        table_schema = QDL::Globals.seq_db_schema[table_name]
        raise "No schema found for table #{table_name}." unless table_schema
        arg_schema = get_schema(table_schema.elts)  ## look up table schema for argument
        raise QDL::Typecheck::StaticTypeError, "No column #{arg_join_column} for arg in call to `join`." if arg_schema[arg_join_column].nil?
        result_schema = receiver_schema.merge(arg_schema).merge({ __all_joined: QDL::Type::UnionType.new(*[receiver_param[:__all_joined], targ1]), __last_joined: targ1, __selected: receiver_param[:__selected], __orm: receiver_param[:__orm] })  ## resulting schema as hash
        result_fht = QDL::Type::FiniteHashType.new(result_schema, nil) ## resulting schema as FiniteHashType

        return QDL::Type::GenericType.new(trec.base, result_fht)
      when QDL::Type::NominalType, QDL::Type::VarType
      ## TODO: this will catch case that first argument is a non-singleton Symbol
        raise "not implemented, likely not needed in practice"
      else
        raise QDL::Typecheck::StaticTypeError, "Unexpected type of first argument to `join`."
      end
    when QDL::Type::NominalType
      raise QDL::Typecheck::StaticTypeError unless trec.name == "Table"
    else
      raise QDL::Typecheck::StaticTypeError, "Unexpected receiver type in call to `join`."
    end
  end
  QDL.type Table, 'self.join_ret_type', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", typecheck: :type_code, wrap: false


  type :insert, "(``insert_arg_type(trec, targs)``) -> Integer", wrap: false
  type :insert, "(``insert_arg_type(trec, targs, true)``, %any) -> Integer", wrap: false
  type :where, "(``where_arg_type(trec, targs)``) -> self", wrap: false
  type :where, "(``where_arg_type(trec, targs, true)``, %any) -> self", wrap: false
  type :exclude, "(``where_arg_type(trec, targs)``) -> self", wrap: false
  type :exclude, "(``where_arg_type(trec, targs, true)``, %any) -> self", wrap: false
  type :[], "(``where_arg_type(trec, targs)``) -> ``first_output(trec)``", wrap: false
  type :first, "() -> ``first_output(trec)``", wrap: false
  type :first, "(``if targs[0] then where_arg_type(trec, targs) else QDL::Globals.types[:bot] end``) -> ``first_output(trec)``", wrap: false
  type :get, '(``get_input(trec)``) -> ``get_output(trec, targs)``', wrap: false
  type :order, '(``order_input(trec, targs)``) -> self', wrap: false
  type Sequel, 'self.desc', '(%any) -> ``targs[0]``', wrap: false ## args will ultimately be checked by `order`
  type :select_map, '(Symbol) -> ``select_map_output(trec, targs, :select_map)``', wrap: false
  type :pluck, '(Symbol) -> ``select_map_output(trec, targs, :select_map)``', wrap: false
  type :any?, "() -> %bool", wrap: false
  type :select, "(*%any) -> ``select_map_output(trec, targs, :select)``", wrap: false
  type :all, "() -> ``all_output(trec)``", wrap: false
  type Sequel, 'self.lit', "(%any) -> String", wrap: false
  type :server, "(Symbol) -> self", wrap: false
  type :empty?, '() -> %bool', wrap: false
  type :update, "(``insert_arg_type(trec, targs)``) -> Integer", wrap: false
  type :count, "() -> Integer", wrap: false
  type :map, "() { (``map_block_input(trec)``) -> x } -> Array<x>", wrap: false
  type :each, "() { (``map_block_input(trec)``) -> x } -> self", wrap: false
  type :import, "(``import_arg_type(trec, targs)``, Array<y>) -> Array<String>", wrap: false
  type :limit, "(Integer) -> self", wrap: false

  def self.order_input(trec, targs)
    case trec
    when QDL::Type::GenericType
      trp0 = QDL.type_cast(trec.params[0], "QDL::Type::FiniteHashType", force: true)
      sym_keys = get_schema(trp0.elts).keys
      all_joined = get_all_joined(trp0.elts[:__all_joined])
      targs.each { |a|
        case a
        when QDL::Type::SingletonType
          return QDL::Globals.types[:bot] unless sym_keys.include?(a.val)
        when QDL::Type::GenericType
          return QDL::Globals.types[:bot] unless a.base.name == "SeqQualIdent"
          check_qual_column(a, all_joined)
        else
          raise "unexpected arg type #{a}"
        end
      }
      return QDL::Type::VarargType.new(QDL::Type::UnionType.new(*targs))
    else
      raise "unexpected type #{trec}"
    end
  end
  QDL.type Table, 'self.order_input', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", typecheck: :type_code, wrap: false

  def self.map_block_input(trec)
    schema = get_schema(QDL.type_cast(trec.params[0], "QDL::Type::FiniteHashType", force: true).elts)
    QDL::Type::FiniteHashType.new(schema, nil)
  end
  QDL.type Table, 'self.map_block_input', "(QDL::Type::GenericType) -> QDL::Type::FiniteHashType", typecheck: :type_code, wrap: false

  def self.all_output(trec)
    f = first_output(trec)
    if f.is_a?(QDL::Type::FiniteHashType)
      trp0 = QDL.type_cast(QDL.type_cast(trec, "QDL::Type::GenericType").params[0], "QDL::Type::FiniteHashType", force: true)
      selected = trp0.elts[:__selected]
      all_joined = get_all_joined(trp0.elts[:__all_joined])
      if !(selected == QDL::Globals.types[:nil])
        ## something is selected
        sel_arr = QDL.type_cast(selected.is_a?(QDL::Type::UnionType) ? QDL.type_cast(selected, "QDL::Type::UnionType").types : [selected], "Array<QDL::Type::SingletonType<Symbol>>", force: true)
        new_hash = Hash[sel_arr.map { |sel|
          if sel.val.to_s.include?("__")
            t = check_qual_column(sel.val, all_joined)
            _, col_name = sel.val.to_s.split "__"
            col_name = col_name.to_sym
            [col_name, t]
          else
            raise "no selected column found" unless (t = QDL.type_cast(f, "QDL::Type::FiniteHashType", force: true).elts[sel.val])
            [sel.val, t]
          end
        }]
        new_hash_type = QDL::Type::FiniteHashType.new(QDL.type_cast(new_hash, "Hash<%any, QDL::Type::Type>", force: true), nil)
        return QDL::Type::GenericType.new(QDL::Globals.types[:array], new_hash_type)
      else
        return QDL::Type::GenericType.new(QDL::Globals.types[:array], f)
      end
    else
      return QDL::Type::GenericType.new(QDL::Globals.types[:array], f)
    end
  end
  QDL.type Table, 'self.all_output', "(QDL::Type::Type) -> QDL::Type::GenericType", typecheck: :type_code, wrap: false

  def self.select_map_output(trec, targs, meth)
    raise "VarargType not supported for select_map." if meth == :select_map && targs[0].is_a?(QDL::Type::VarargType)
    return trec if targs[0].is_a?(QDL::Type::VarargType)
    case trec
    when QDL::Type::GenericType
      raise QDL::Typecheck::StaticTypeError, 'unexpected type' unless trec.base.name == "Table"
      receiver_param = QDL.type_cast(trec.params[0], "QDL::Type::FiniteHashType", force: true).elts
      all_joined = get_all_joined(receiver_param[:__all_joined])

      map_types = targs.map { |arg|
        case arg
        when QDL::Type::SingletonType
          column = QDL.type_cast(arg.val, "Symbol", force: true)
          raise "unexpected arg type #{arg}" unless column.is_a?(Symbol)
          raise "Ambiguous column identifier #{arg}." unless unique_ids?([column], receiver_param[:__all_joined])
          if column.to_s.include?("__")
            check_qual_column(column, all_joined)
          else
            raise "No column #{column} in receiver table." unless receiver_param[column]
            receiver_param[column]
          end
        when QDL::Type::GenericType
          raise "unexpected arg type #{arg}" unless arg.base.name == "SeqQualIdent"
          check_qual_column(arg, all_joined)
        else
          raise "unexpected arg type #{arg}"
        end
      }

      targs.each { |arg|
        case arg
        when QDL::Type::SingletonType
          column = QDL.type_cast(arg.val, "Symbol", force: true)
          raise "unexpected arg type #{arg}" unless column.is_a?(Symbol)
          raise "Ambiguous column identifier #{arg}." unless unique_ids?([column], receiver_param[:__all_joined])
          if column.to_s.include?("__")
            map_types = map_types + [check_qual_column(column, all_joined)]
          else
            raise "No column #{column} in receiver table." unless receiver_param[column]
            map_types = map_types + [receiver_param[column]]
          end
        when QDL::Type::GenericType
          raise "unexpected arg type #{arg}" unless arg.base.name == "SeqQualIdent"
          map_types = map_types + [check_qual_column(arg, all_joined)]
        else
          raise "unexpected arg type #{arg}"
        end
      }
      if meth == :select
        result_schema = receiver_param.clone.merge({ __selected: QDL::Type::UnionType.new(*targs).canonical })
        return QDL::Type::GenericType.new(trec.base, QDL::Type::FiniteHashType.new(result_schema, nil))
      elsif meth == :select_map
        if targs.size >1
          return QDL::Type::GenericType.new(QDL::Globals.types[:array], QDL::Type::TupleType.new(*map_types))
        else
          return QDL::Type::GenericType.new(QDL::Globals.types[:array], map_types[0])
        end
      else
        raise 'unexpected'
      end
    else
      raise 'unexpected type #{trec}'
    end
  end
  QDL.type Table, 'self.select_map_output', "(QDL::Type::Type, Array<QDL::Type::Type>, Symbol) -> QDL::Type::GenericType", typecheck: :type_code, wrap: false

  def self.get_input(trec)
    case trec
    when QDL::Type::GenericType
      sym_keys = get_schema(QDL.type_cast(trec.params[0], "QDL::Type::FiniteHashType", force: true).elts).keys
      QDL::Type::UnionType.new(*QDL.type_cast(sym_keys.map { |k| QDL::Type::SingletonType.new(k) }, "Array<QDL::Type::Type>"))
    else
      raise 'unexpected type #{trec}'
    end
  end
  QDL.type Table, 'self.get_input', "(QDL::Type::Type) -> QDL::Type::UnionType", typecheck: :type_code, wrap: false

  def self.get_output(trec, targs)
    QDL.type_cast(QDL.type_cast(trec, "QDL::Type::GenericType").params[0], "QDL::Type::FiniteHashType", force: true).elts[QDL.type_cast(targs[0], "QDL::Type::SingletonType<Symbol>", force: true).val]
  end
  QDL.type Table, 'self.get_output', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", typecheck: :type_code, wrap: false

  def self.first_output(trec)
    case trec
    when QDL::Type::GenericType
      raise QDL::Typecheck::StaticTypeError, 'unexpected type' unless trec.base.name == "Table"
      receiver_param = QDL.type_cast(trec.params[0], "QDL::Type::FiniteHashType", force: true).elts
      if !(receiver_param[:__orm] == QDL::Globals.types[:false])
        receiver_param[:__orm]
      else
        QDL::Type::FiniteHashType.new(get_schema(receiver_param), nil)
      end
    else
      raise 'unexpected type #{trec}'
    end
  end
  QDL.type Table, 'self.first_output', "(QDL::Type::Type) -> QDL::Type::Type", typecheck: :type_code, wrap: false

  def self.insert_arg_type(trec, targs, tuple=false)
    raise "Cannot insert/update for joined table." if QDL.type_cast(QDL.type_cast(trec, "QDL::Type::GenericType").params[0], "QDL::Type::FiniteHashType", force: true).elts[:__all_joined].is_a?(QDL::Type::UnionType)
    if tuple
      schema_arg_tuple_type(trec, targs, :insert)
    else
      schema_arg_type(trec, targs, :insert)
    end
  end
  QDL.type Table, 'self.insert_arg_type', "(QDL::Type::Type, Array<QDL::Type::Type>, ?%bool) -> QDL::Type::Type", typecheck: :type_code, wrap: false

  def self.import_arg_type(trec, targs)
    raise "Cannot import for joined table." if QDL.type_cast(QDL.type_cast(trec, "QDL::Type::GenericType").params[0], "QDL::Type::FiniteHashType", force: true).elts[:__all_joined].is_a?(QDL::Type::UnionType)
    raise "Expected tuple for first arg to `import`, got #{targs[0]} instead." unless targs[0].is_a?(QDL::Type::TupleType)
    arg1 = targs[1]
    case arg1
    when QDL::Type::TupleType
      arg1.params.each { |t| schema_arg_tuple_type(trec, [targs[0], t], :import) } ## check each individual tuple inside second arg tuple
    when QDL::Type::GenericType
      raise "expected Array, got #{arg1}" unless (arg1.base == QDL::Globals.types[:array])
      raise "`import` type not yet implemented for type #{arg1}" unless arg1.params[0].is_a?(QDL::Type::TupleType) 
      schema_arg_tuple_type(trec, [targs[0], arg1.params[0]], :import)
    when QDL::Type::VarType
      schema_arg_tuple_type(trec, targs, :import)
    else
      raise "Not yet implemented for type #{arg1}."
    end
    return targs[0]
  end
  QDL.type Table, 'self.import_arg_type', "(QDL::Type::Type, Array<QDL::Type::Type>) -> QDL::Type::Type", typecheck: :type_code, wrap: false

  def self.get_nominal_where_type(type)
    ## `where` can accept arrays/tuples and tables with a single column selected
    ## this method just extracts the parameter type
    case type
    when QDL::Type::GenericType
      if type.base == QDL::Globals.types[:array]
        type.params[0]
      elsif type.base == QDL::Type::NominalType.new(Table)
        schema = QDL.type_cast(type.params[0], "QDL::Type::FiniteHashType", force: true).elts
        sel = schema[:__selected]
        raise "Call to where expects table with a single column selected, got #{type}" unless sel.is_a?(QDL::Type::SingletonType)
        nominal = schema[QDL.type_cast(sel, "QDL::Type::SingletonType", force: true).val]
        raise "No type found for column #{sel} in call to `where`." unless nominal
        nominal
      else
        type
      end
    when QDL::Type::TupleType
      type = type.promote.params[0]
      raise "`where` passed tuple containing different types." if type.is_a?(QDL::Type::UnionType)
      type
    when QDL::Type::VarType
      raise "not implemented"
    else
      type
    end
  end

  QDL.type Table, 'self.get_nominal_where_type', "(QDL::Type::Type) -> QDL::Type::Type", typecheck: :type_code, wrap: false

  def self.schema_arg_type(trec, targs, meth)
    return QDL::Type::NominalType.new(Hash) if targs.size != 1
    case trec
    when QDL::Type::GenericType
      raise QDL::Typecheck::StaticTypeError, 'unexpected type' unless trec.base.name == "Table"
      receiver_param = QDL.type_cast(trec.params[0], "QDL::Type::FiniteHashType", force: true).elts
      receiver_schema = get_schema(receiver_param)
      all_joined = get_all_joined(receiver_param[:__all_joined])
      arg0 = targs[0]
      case arg0
      when QDL::Type::FiniteHashType
        insert_hash = arg0.elts
        insert_hash.each { |column_name, type|
          cn = QDL.type_cast(column_name, "Symbol", force: true)
          if cn.to_s.include?("__") && (meth == :where)
            check_qual_column(cn, all_joined, type)
          else
            raise QDL::Typecheck::StaticTypeError, "No column #{column_name} for receiver #{trec}." unless receiver_schema.has_key?(cn)
            if meth == :where
              type = get_nominal_where_type(type) unless type.is_a?(QDL::Type::VarType)
              upper_type = QDL::Type::UnionType.new(receiver_schema[cn], QDL::Type::GenericType.new(QDL::Globals.types[:array], receiver_schema[cn]))
            else
              upper_type = receiver_schema[cn]
            end
            raise QDL::Typecheck::StaticTypeError, "Incompatible column types #{type} and #{receiver_schema[column_name]} for column #{cn} in call to #{meth}." unless QDL::Type::Type.leq(type, upper_type)
          end
        }
        return arg0
      when QDL::Type::GenericType
        raise QDL::Typecheck::StaticTypeError, "unexpected type #{arg0}" unless arg0.base.name == "Hash"
        return QDL::Globals.parser.scan_str "#T Hash<Symbol, %any>"
      when QDL::Type::NominalType
        raise QDL::Typecheck::StaticTypeError, "unexpected type #{arg0}" unless arg0.name == "Hash"
        return arg0
      else
        return arg0 if (meth==:where) && targs[0] <= QDL::Globals.types[:string]
        #raise "TODO WITH #{trec} AND #{targs} AND #{meth}"
        return QDL::Globals.types[:bot]
      end
    when QDL::Type::NominalType
     raise "TODO"
    else

    end
  end
  QDL.type Table, 'self.schema_arg_type', "(QDL::Type::Type, Array<QDL::Type::Type>, Symbol) -> QDL::Type::Type", typecheck: :type_code, wrap: false

  ## [+ column_name +] is a symbol or SeqQualIdent Generic type of the qualified column name, e.g. :person__age
  ## [+ all_joined +] is an array of symbols of joined tables (must check if qualifying table is a member)
  ## [+ type +] is optional QDL type. If given, we check that it matches the type of the column in the schema.
  ## returns type of given column
  def self.check_qual_column(column_name, all_joined, type=nil)
    case column_name
    when QDL::Type::GenericType
      cn = QDL.type_cast(column_name, "QDL::Type::GenericType", force: true)
      raise "Expected qualified column type." unless cn.base.name == "SeqQualIdent"
      qual_table, qual_column = cn.params.map { |t| QDL.type_cast(t, "QDL::Type::SingletonType<Symbol>", force: true).val }
    else
      ## symbol with name including underscores
      qual_table, qual_column = QDL.type_cast(column_name, "Symbol", force: true).to_s.split "__"
      qual_table = if qual_table.start_with?(":") then qual_table[1..-1].to_sym else qual_table.to_sym end
      qual_column = qual_column.to_sym
    end
    raise QDL::Typecheck::StaticTypeError, "qualified table #{qual_table} is not joined in receiver table, cannot reference its columns" unless all_joined.include?(qual_table)
    qual_table_schema = get_schema(QDL::Globals.seq_db_schema[qual_table].elts)
    raise QDL::Typecheck::StaticTypeError, "No column #{qual_column} in table #{qual_table}." if qual_table_schema[qual_column].nil?
    if type #&& !type.is_a?(QDL::Type::VarType)
      types = (if type.is_a?(QDL::Type::UnionType) then QDL.type_cast(type, "QDL::Type::UnionType", force: true).types else [type] end)
      types.each { |t|
        t = QDL.type_cast(t, "QDL::Type::GenericType", force: true).params[0] if t.is_a?(QDL::Type::GenericType) && (QDL.type_cast(t, "QDL::Type::GenericType", force: true).base == QDL::Globals.types[:array]) ## only happens if meth is where, don't need to check
        union_with_array = QDL::Type::UnionType.new(qual_table_schema[qual_column], QDL::Type::GenericType.new(QDL::Globals.types[:array], qual_table_schema[qual_column]))
        raise QDL::Typecheck::StaticTypeError, "Incompatible column types. Given #{t} but expected #{qual_table_schema[qual_column]} for column #{column_name}." unless QDL::Type::Type.leq(t, union_with_array)
      }
    end
    return qual_table_schema[qual_column]
  end
  QDL.type Table, 'self.check_qual_column', "(Symbol or QDL::Type::GenericType, Array<Symbol>, ?QDL::Type::Type) -> QDL::Type::Type", typecheck: :type_code, wrap: false

  def self.schema_arg_tuple_type(trec, targs, meth)
    return QDL::Type::NominalType.new(Array) if targs.size != 2
    case trec
    when QDL::Type::GenericType
      raise QDL::Typecheck::StaticTypeError, 'unexpected type' unless trec.base.name == "Table"
      receiver_param = QDL.type_cast(trec.params[0], "QDL::Type::FiniteHashType", force: true).elts
      all_joined = get_all_joined(receiver_param[:__all_joined])
      receiver_schema = get_schema(receiver_param)
      if targs[0].is_a?(QDL::Type::TupleType) && targs[1].is_a?(QDL::Type::TupleType)
        QDL.type_cast(targs[0], "QDL::Type::TupleType", force: true).params.each_with_index { |column_name, i|
          cn = QDL.type_cast(column_name, "QDL::Type::SingletonType<Symbol>", force: true)
          raise "Expected singleton symbol in call to insert, got #{column_name}" unless cn.is_a?(QDL::Type::SingletonType) && cn.val.is_a?(Symbol)
          type = QDL.type_cast(targs[1], "QDL::Type::TupleType", force: true).params[i]
          if cn.val.to_s.include?("__") && (meth == :where)
            check_qual_column(cn.val, all_joined, type)
          else
            raise QDL::Typecheck::StaticTypeError, "No column #{column_name} for receiver in call to `insert`." unless receiver_schema.has_key?(cn.val)
            if meth == :where
              type = get_nominal_where_type(type)
              upper_type = QDL::Type::UnionType.new(receiver_schema[cn.val], QDL::Type::GenericType.new(QDL::Globals.types[:array], receiver_schema[cn.val]))
            else
              upper_type = receiver_schema[cn.val]
            end            
            raise QDL::Typecheck::StaticTypeError, "Incompatible column types #{type} and #{upper_type}." unless QDL::Type::Type.leq(type, upper_type)
          end
        }
        return targs[0]
      elsif targs[0].is_a?(QDL::Type::TupleType) && targs[1].is_a?(QDL::Type::VarType)
        new_tuple = []
        targs[0].params.each_with_index { |column_name, i|
          raise "Expected singleton symbol in call to insert, got #{column_name}" unless column_name.is_a?(QDL::Type::SingletonType) && column_name.val.is_a?(Symbol)
          if column_name.val.to_s.include?("__") && (meth == :where)
            raise "not yet implemented"
          else
            raise QDL::Typecheck::StaticTypeError, "No column #{column_name} for receiver in call to `insert`." unless receiver_schema.has_key?(column_name.val)
            if meth == :where
              upper_type = QDL::Type::UnionType.new(receiver_schema[column_name.val], QDL::Type::GenericType.new(QDL::Globals.types[:array], receiver_schema[column_name.val]))
            else
              upper_type = receiver_schema[column_name.val]
            end
            new_tuple <<  upper_type
          end
        }
        if meth == :import
          QDL::Type::Type.leq(targs[1], QDL::Type::GenericType.new(QDL::Globals.types[:array], QDL::Type::TupleType.new(*new_tuple).promote))
        else
          QDL::Type::Type.leq(targs[1], QDL::Type::TupleType.new(*new_tuple))
        end
        return targs[0]
      else
        raise "not yet implemented for types #{targs[0]} and #{targs[1]}"
      end
    else
      raise 'not yet implemented'
    end
  end
  QDL.type Table, 'self.schema_arg_tuple_type', "(QDL::Type::Type, Array<QDL::Type::Type>, Symbol) -> QDL::Type::Type", typecheck: :type_code, wrap: false

  def self.where_arg_type(trec, targs, tuple=false)
    return targs[0] if targs[0] == QDL::Globals.types[:string]
    trp0 = QDL.type_cast(QDL.type_cast(trec, "QDL::Type::GenericType").params[0], "QDL::Type::FiniteHashType", force: true)
    if trp0.elts[:__all_joined].is_a?(QDL::Type::UnionType)
      arg0 = targs[0]
      case arg0
      when QDL::Type::TupleType
        raise "Unexpected column type." unless arg0.params.all? { |t| t.is_a?(QDL::Type::SingletonType) && QDL.type_cast(t, "QDL::Type::SingletonType<Object>", force: true).val.is_a?(Symbol) }
        raise "Ambigious identifier in call to where." unless unique_ids?(arg0.params.map { |t| QDL.type_cast(t, "QDL::Type::SingletonType<Symbol>", force: true).val }, trp0.elts[:__all_joined])
      when QDL::Type::FiniteHashType
        raise "Ambigious identifier in call to where." unless unique_ids?(QDL.type_cast(arg0.elts.keys, "Array<Symbol>", force: true), trp0.elts[:__all_joined])
      else
        if arg0.is_a?(QDL::Type::GenericType) && arg0.base.name == "Hash" && arg0.params[0].is_a?(QDL::Type::GenericType) && arg0.params[0].base.name == "SeqQualIdent"
        ## this case is for when the given column name is a Sequel Qualified Identifier (SeqQualIdent)
        ## If so, we will convert it to a symbol.
          check_qual_column(arg0.params[0], get_all_joined(trp0.elts[:__all_joined]), arg0.params[1])
          return arg0
        else
          raise "unexpected arg type #{arg0} of kind #{arg0.class}"
        end
      end
    end
    if tuple
      ret = schema_arg_tuple_type(trec, targs, :where)
      return ret
    else
      ret = schema_arg_type(trec, targs, :where)
      return ret
    end
  end
  QDL.type Table, 'self.where_arg_type', "(QDL::Type::Type, Array<QDL::Type::Type>, ?%bool) -> QDL::Type::Type", typecheck: :type_code, wrap: false

  def self.unique_ids?(ids, joined)
    j = get_all_joined(joined)
    count = Hash[ids.map { |id| [id, 0] }]

    j.each { |t1|
      schema1 = QDL::Globals.seq_db_schema[t1]
      raise "schema not found" unless schema1
      j.each { |t2|
        schema2 = QDL::Globals.seq_db_schema[t2]
        ids.each { |id|
          return false if schema1.elts.has_key?(id) && schema2.elts.has_key?(id) && (t1 != t2)
        }
      }
    }
    return true
  end
  QDL.type Table, 'self.unique_ids?', "(Array<Symbol>, QDL::Type::Type) -> %bool", typecheck: :type_code, wrap: false

end
