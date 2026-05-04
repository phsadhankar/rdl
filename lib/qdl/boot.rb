require 'delegate'
require 'digest'
require 'set'
require 'parser/current'
#require 'method_source'
require 'colorize'
require 'pathname'
require 'rake'
require 'net/http'

module QDL
end

require 'qdl/config.rb'
require 'qdl/logging.rb'
def QDL.config
  yield(QDL::Config.instance)
end
require 'qdl/info.rb'

module QDL::Globals
  FIXBIG_VERSIONS = ['>= 2.0.0', '< 2.4.0']

  # Method/variable info table with kinds:
  # For methods
  #   :pre to array of precondition contracts
  #   :post to array of postcondition contracts
  #   :type to array of types
  #   :source_location to [filename, linenumber] location of most recent definition
  #   :typecheck - boolean that is true if method should be statically type checked
  #   :otype to set of types that were observed at run time, where a type is a finite hash {:args => Array<Class>, :ret => Class, :block => %bool}
  #   :context_types to array of [klass, meth, Type] - method types that exist only within this method. An icky hack to deal with Rails `params`.
  # For variables
  #   :type to type
  @info = QDL::Info.new

  # Map from full_method_name to number of times called when wrapped
  @wrapped_calls = Hash.new 0

  # Hash from class name to array of symbols that are the class's type parameters
  @type_params = Hash.new

  # Hash from class name to method name to its alias method name
  # class names are strings
  # method names are symbols
  @aliases = Hash.new

  # Set of [class, method] pairs to wrap.
  # class is a string
  # method is a symbol
  @to_wrap = Set.new

  # Map from symbols to set of [class, method] pairs to type check when those symbols are qdl_do_typecheck'd
  # (or the methods are defined, for the symbol :now)
  @to_typecheck = Hash.new
  @to_typecheck[:now] = Set.new

  # Map from symbols to set of [class, method] pairs to infer when those symbols are qdl_do_infer'd
  # (or the methods are defined, for the symbol :now)
  @to_infer = Hash.new
  @to_infer[:now] = Set.new

  ## List of [klass, method] pairs for which we have generated constraints.
  ## That is, if we look up QDL::Globals.info.get(klass, meth, :type), we will get a single MethodType
  ## composed of VarTypes with constraints.
  ## TODO: add inst/class vars to this list?
  @constrained_types = []

  # Map from symbols to Array<Proc> where the Procs are called when those symbols are qdl_do_typecheck'd
  @to_do_at = Hash.new

  # List of contracts that should be applied to the next method definition
  @deferred = []

  # List of method types that have a dependent type. Used to type check type-level code.
  @dep_types = []

  ## Hash mapping node object IDs (integers) to a list [tmeth, tmeth_old, tmeth_res, self_klass, trecv_old, targs_old], where: tmeth is a MethodType that is fully evaluated (i.e., no ComputedTypes) *and instantiated*, tmeth_old is the unevaluated method type (i.e., with ComputedTypes), tmeth_res is the result of evaluating tmeth_old *but not instantiating it*, self_klass is the class where the MethodType is defined, trecv_old was the receiver type used to evaluate tmeth_old, and targs_old is an Array of the argument types used to evaluate tmeth_old.
  @comp_type_map = Hash.new

  # Map from ActiveRecord table names (symbols) to their schema types, which should be a Table type
  @ar_db_schema = Hash.new

  # Map from Sequel table names (symbols) to their schema types, which should be a Table type
  @seq_db_schema = Hash.new

  # Array<[String, String]>, where each first string is a class name and each second one is a method name.
  # klass/method pairs here should not be inferred.
  @no_infer_meths = []

  # Array<String> of absolute file paths for files that should not be inferred.
  @no_infer_files = []

  # If non-nil, should be a symbol. Added, untyped methods will be tagged
  # with that symbol
  @infer_added = nil

  # Hash<Module module, [Class/Module class/module_name, :include or :extend]>
  # Map from module names k to pairs [class/module v, :include/:extend] indicating the module
  # k was included/extended in v
  @module_mixees = Hash.new
end

class << QDL::Globals # add accessors and readers for module variables
  attr_accessor :info
  attr_accessor :wrapped_calls
  attr_accessor :type_params
  attr_reader :aliases
  attr_accessor :to_wrap
  attr_accessor :to_typecheck
  attr_accessor :to_infer
  attr_accessor :constrained_types
  attr_accessor :to_do_at
  attr_accessor :deferred
  attr_accessor :dep_types
  attr_accessor :comp_type_map
  attr_accessor :ar_db_schema
  attr_accessor :seq_db_schema
  attr_accessor :no_infer_meths
  attr_accessor :no_infer_files
  attr_accessor :infer_added
  attr_accessor :infer_added_filter_dirs
  attr_accessor :module_mixees
end

# Create switches to control whether wrapping happens and whether
# contracts are checked. These need to be created before qdl/wrap.rb
# is loaded.
require 'qdl/switch.rb'
module QDL::Globals
  @wrap_switch = QDL::Switch.new
  @contract_switch = QDL::Switch.new
end

class << QDL::Globals
  attr_reader :wrap_switch
  attr_reader :contract_switch
end

require 'qdl/types/type.rb'
require 'qdl/types/annotated_arg.rb'
require 'qdl/types/bound_arg.rb'
require 'qdl/types/bot.rb'
require 'qdl/types/computed.rb'
require 'qdl/types/dependent_arg.rb'
require 'qdl/types/dots_query.rb'
require 'qdl/types/dynamic.rb'
require 'qdl/types/finite_hash.rb'
require 'qdl/types/generic.rb'
require 'qdl/types/intersection.rb'
require 'qdl/types/lexer.rex.rb'
require	'qdl/types/method.rb'
require 'qdl/types/singleton.rb'
require 'qdl/types/ast_node.rb'
require 'qdl/types/nominal.rb'
require	'qdl/types/non_null.rb'
require 'qdl/types/optional.rb'
require 'qdl/types/parser.tab.rb'
require 'qdl/types/structural.rb'
require 'qdl/types/top.rb'
require 'qdl/types/tuple.rb'
require 'qdl/types/type_query.rb'
require 'qdl/types/union.rb'
require 'qdl/types/var.rb'
require 'qdl/types/choice.rb' ## depends on var.rb
require	'qdl/types/vararg.rb'
require 'qdl/types/wild_query.rb'
require	'qdl/types/string.rb'

require 'qdl/contracts/contract.rb'
require 'qdl/contracts/and.rb'
require 'qdl/contracts/flat.rb'
require 'qdl/contracts/or.rb'
require 'qdl/contracts/proc.rb'

require 'qdl/util.rb'
require 'qdl/class_indexer.rb'
require 'qdl/wrap.rb'
require 'qdl/query.rb'
require 'qdl/typecheck.rb'
require 'qdl/reporting/reporting.rb'
require 'qdl/constraint.rb'
require 'qdl/heuristics.rb'
#require_relative 'qdl/stats.rb'

class << QDL::Globals
  attr_reader :parser
  attr_accessor :parser_cache
  attr_reader :types
  attr_reader :special_types
end

module QDL
  def self.reset
    QDL::Globals.module_eval {
      QDL::Config.reset
      @info = QDL::Info.new
      @wrapped_calls = Hash.new 0
      @type_params = Hash.new
      @aliases = Hash.new
      @to_wrap = Set.new
      @to_typecheck = Hash.new
      @to_typecheck[:now] = Set.new
      @to_infer = Hash.new
      @to_infer[:now] = Set.new
      @constrained_types = []
      @to_do_at = Hash.new
      @deferred = []
      # @dep_types = []
      # @comp_type_map = Hash.new
      @ar_db_schema = Hash.new
      @seq_db_schema = Hash.new
      @no_infer_meths = []
      @no_infer_files = []
      @infer_added = nil
      # @module_mixees = Hash.new - resetting this breaks test cases that assume
      # we know which modules are mixed into which other modules

      @parser = QDL::Type::Parser.new

      # Map from file names to [digest, cache] where 2nd elt maps
      #  :ast to the AST
      #  :line_defs maps linenumber to AST for def at that line
      @parser_cache = Hash.new

      # Some generally useful types; not really a big deal to do this since
      # NominalTypes are cached, but these names are shorter to type
      @types = Hash.new
      @types[:nil] = QDL::Type::NominalType.new NilClass # actually creates singleton type
      @types[:top] = QDL::Type::TopType.new
      @types[:bot] = QDL::Type::BotType.new
      @types[:dyn] = QDL::Type::DynamicType.new
      @types[:object] = QDL::Type::NominalType.new Object
      @types[:true] = QDL::Type::NominalType.new TrueClass # actually creates singleton type
      @types[:false] = QDL::Type::NominalType.new FalseClass # also singleton type
      @types[:bool] = QDL::Type::UnionType.new(@types[:true], @types[:false])
      @types[:float] = QDL::Type::NominalType.new Float
      @types[:complex] = QDL::Type::NominalType.new Complex
      @types[:rational] = QDL::Type::NominalType.new Rational
      @types[:integer] = QDL::Type::NominalType.new Integer
      @types[:numeric] = QDL::Type::NominalType.new Numeric
      @types[:string] = QDL::Type::NominalType.new String
      @types[:array] = QDL::Type::NominalType.new Array
      @types[:hash] = QDL::Type::NominalType.new Hash
      @types[:symbol] = QDL::Type::NominalType.new Symbol
      @types[:range] = QDL::Type::NominalType.new Range
      @types[:regexp] = QDL::Type::NominalType.new Regexp
      @types[:standard_error] = QDL::Type::NominalType.new StandardError
      @types[:proc] = QDL::Type::NominalType.new Proc

      # Hash from special type names to their values
      @special_types = {'%any' => @types[:top],
                        '%bot' => @types[:bot],
                        '%bool' => @types[:bool],
                        '%dyn' => @types[:dyn]}
    }
  end
end

QDL.reset
require 'qdl/types/qdl_types.rb'
