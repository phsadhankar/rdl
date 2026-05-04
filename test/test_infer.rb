# frozen_string_literal: true

require 'colorize'
require 'coderay'

require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'qdl'
require 'types/core'

# Testing Inference (constraint.rb)
class TestInfer < Minitest::Test
  extend QDL::Annotate

  def setup
    QDL.reset
    QDL::Config.instance.number_mode = true

    # TODO: this will go away after config/reset
    QDL::Config.instance.use_precise_string = false
    QDL::Config.instance.log_levels[:inference] = :error
    # QDL::Config.instance.log_levels[:inference] = :debug

    QDL.readd_comp_types
    QDL.type_params :Hash, [:k, :v], :all? unless QDL::Globals.type_params['Hash']
    QDL.type_params :Array, [:t], :all? unless QDL::Globals.type_params['Array']
    # QDL.qdl_alias :Array, :size, :length
    QDL.nowrap :Range
    QDL.type_params 'QDL::Type::SingletonType', [:t], :satisfies? unless QDL::Globals.type_params['QDL::Type::SingletonType']
    QDL.type_params(:Range, [:t], nil, variance: [:+]) { |t| t.member?(self.begin) && t.member?(self.end) } unless QDL::Globals.type_params['Range']
    QDL.type :Range, :each, '() { (t) -> %any } -> self'
    QDL.type :Range, :each, '() -> Enumerator<t>'
    QDL.type :Integer, :to_s, '() -> String', wrap: false
    QDL.type :Kernel, 'self.puts', '(*[to_s : () -> String]) -> nil', wrap: false
    QDL.type :Kernel, :raise, '() -> %bot', wrap: false
    QDL.type :Kernel, :raise, '(String) -> %bot', wrap: false
    QDL.type :Kernel, :raise, '(Class, ?String, ?Array<String>) -> %bot', wrap: false
    QDL.type :Kernel, :raise, '(Exception, ?String, ?Array<String>) -> %bot', wrap: false
    QDL.type :Object, :===, '(%any other) -> %bool', wrap: false
    QDL.type :Object, :clone, '() -> self', wrap: false
    QDL.type :NilClass, :&, '(%any obj) -> false', wrap: false
    QDL.type :Hash, :merge, '(Hash<a, b>) -> Hash<k or a, b or v>', wrap: false

    ### Uncomment below to see test names. Useful for hanging tests.
    # puts "Start #{@NAME}"
  end

  # TODO: this will go away after config/reset
  def teardown
    QDL::Config.instance.number_mode = false
    QDL::Config.instance.use_unknown_types = false # set in do_infer
  end

  # convert a string to a method type
  def tm(typ)
    QDL::Globals.parser.scan_str('#Q ' + typ)
  end

  def infer_method_type(method, depends_on: [])
    depends_on.each { |m| QDL.infer self.class, m, time: :test }

    QDL.infer self.class, method, time: :test
    QDL.do_infer :test, render_report: false

    types = QDL::Globals.info.get 'TestInfer', method, :type
    assert types.length == 1, msg: 'Expected one solution for type'

    types[0]
  end

  def assert_type_equal(meth, expected_type, depends_on: [])
    typ = infer_method_type meth, depends_on: depends_on
    QDL::Type::VarType.no_print_XXX!

    if expected_type != typ.solution
      ast  = QDL::Typecheck.get_ast(self.class, meth)
      code = CodeRay.scan(ast.loc.expression.source, :ruby).term

      error_str  = 'Given'.yellow + ":\n  #{code}\n\n"
      error_str += 'Expected '.green + expected_type.to_s + "\n"
      error_str += 'Got      '.red + typ.solution.to_s
    end

    assert expected_type.match(typ.solution), error_str
  end

  def self.should_have_type(meth, typ, depends_on: [], shouldSkip: false)
    define_method "test_#{meth}" do
      if shouldSkip
        skip
      end
      assert_type_equal meth, tm(typ), depends_on: depends_on
    end
  end

  # ----------------------------------------------------------------------------

  def return_two
    2
  end
  should_have_type :return_two, '() -> Integer'

  def return_two_plus_two
    2 + 2
  end
  should_have_type :return_two_plus_two, '() -> Integer'

  def plus_two(val)
    val + 2
  end
  should_have_type :plus_two, '([ +: (Integer) -> a ]) -> b'

  def print_it(val)
    puts val
  end
  should_have_type :print_it, '([ to_s: () -> String ]) -> nil'

  def return_hash
    { a: 1, b: 2, c: 3 }
  end
  should_have_type :return_hash, '() -> { a: Integer, b: Integer, c: Integer }'

  def return_hash_1
    { a: 1, b: 'b', c: :c }
  end
  should_have_type :return_hash_1, '() -> { a: Integer, b: String, c: :c }'

  def return_hash_val(val)
    { a: 1, b: 'b', c: val }
  end
  should_have_type :return_hash_val, '(a) -> { a: Integer, b: String, c: a }'

  def concatenate
    'Hello' + ' World!'
  end
  should_have_type :concatenate, '() -> String'

  def concatenate_1(val)
    'Hello, ' + val
  end
  should_have_type :concatenate_1, '(String) -> String'

  def repeat
    'a' * 5
  end
  should_have_type :repeat, '() -> String'

  def repeat_n(n)
    'a' * n
  end
  should_have_type :repeat_n, '(Numeric) -> String', shouldSkip: true
  # skipped because of `number_mode`.

  # Note: The last type in the unions below comes from requiring `sorbet` (via
  #       requiring `parlour`) to render RBI files. The Structural -> Nominal
  #       heuristic picks up that this might be a valid type this case.
  def note(reason, args, ast)
    Diagnostic.new :note, reason, args, ast.loc.expression
  end
  should_have_type :note, '(a, b, Parser::AST::Node or Parser::Source::Comment or T::Private::Methods::DeclarationBlock) -> Diagnostic'

  def print_note(reason, args, ast)
    puts note(reason, args, ast).render
  end
  should_have_type :print_note, '(a, b, Parser::AST::Node or Parser::Source::Comment or T::Private::Methods::DeclarationBlock) -> nil',
                   depends_on: [:note]

  def compares_struct_with_parametric_method(options = {})
    options.merge({ "test" => 42 })
    42
  end
  should_have_type :compares_struct_with_parametric_method, "(?[ merge: (Hash<String, Integer>) -> a]) -> Integer"
  # Not concerned with specific inferred types here.
  # Want to test that constraint resolution does not fail when using Hash#merge's type,
  # which includes type variables
  
end
