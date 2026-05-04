require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'qdl'

class TestQDL < Minitest::Test
  extend QDL::Annotate

  def setup
    QDL.reset
  end

  # Test wrapping with no types or contracts
  def test_wrap
    def m1(x) return x; end
    def m2(x) return x; end
    def m3(x) return x; end
    def m4(x) return x; end
    assert(not(QDL::Wrap.wrapped?(TestQDL, :m1)))
    assert(not(QDL::Wrap.wrapped?(TestQDL, :m2)))
    assert(not(QDL::Wrap.wrapped?(TestQDL, :m3)))
    assert(not(QDL::Wrap.wrapped?(TestQDL, :m4)))
    QDL::Wrap.wrap(TestQDL, :m1)
    QDL::Wrap.wrap("TestQDL", :m2)
    QDL::Wrap.wrap(:TestQDL, :m3)
    QDL::Wrap.wrap(TestQDL, "m4")
    assert(QDL::Wrap.wrapped?(TestQDL, :m1))
    assert(QDL::Wrap.wrapped?(TestQDL, :m2))
    assert(QDL::Wrap.wrapped?(TestQDL, :m3))
    assert(QDL::Wrap.wrapped?(TestQDL, :m4))
    assert_equal 3, m1(3)
    assert_equal 3, m2(3)
    assert_equal 3, m3(3)
    assert_equal 3, m4(3)
  end

  def test_process_pre_post_args
    ppos = QDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    assert_equal ["TestQDL", :m1, ppos], QDL::Wrap.process_pre_post_args(self.class, "C", TestQDL, :m1, ppos)
    assert_equal ["TestQDL", :m1, ppos], QDL::Wrap.process_pre_post_args(self.class, "C", TestQDL, "m1", ppos)
    assert_equal ["#{QDL::Util::SINGLETON_MARKER}TestQDL", :m1, ppos], QDL::Wrap.process_pre_post_args(self.class, "C", TestQDL, "self.m1", ppos)
    assert_equal ["TestQDL", :m1, ppos], QDL::Wrap.process_pre_post_args(self.class, "C", :m1, ppos)
    assert_equal ["TestQDL", nil, ppos], QDL::Wrap.process_pre_post_args(self.class, "C", ppos)
    klass1, meth1, c1 = QDL::Wrap.process_pre_post_args(self.class, "C", TestQDL, :m1) { |x| x > 0 }
    assert_equal ["TestQDL", :m1], [klass1, meth1]
    assert (c1.is_a? QDL::Contract::FlatContract)

    klass2, meth2, c2 = QDL::Wrap.process_pre_post_args(self.class, "C", :m1) { |x| x > 0 }
    assert_equal ["TestQDL", :m1], [klass2, meth2]
    assert (c2.is_a? QDL::Contract::FlatContract)

    klass3, meth3, c3 = QDL::Wrap.process_pre_post_args(self.class, "C") { |x| x > 0 }
    assert_equal ["TestQDL", nil], [klass3, meth3]
    assert (c3.is_a? QDL::Contract::FlatContract)

    assert_raises(ArgumentError) { QDL::Wrap.process_pre_post_args(self.class, "C") }
    assert_raises(ArgumentError) { QDL::Wrap.process_pre_post_args(self.class, "C", 42) }
    assert_raises(ArgumentError) { QDL::Wrap.process_pre_post_args(self.class, "C", 42) { |x| x > 0} }
    assert_raises(ArgumentError) { QDL::Wrap.process_pre_post_args(self.class, "C", ppos) { |x| x > 0 } }
    assert_raises(ArgumentError) { QDL::Wrap.process_pre_post_args(self.class, "C", :m1) }
    assert_raises(ArgumentError) { QDL::Wrap.process_pre_post_args(self.class, "C", TestQDL) }
    assert_raises(ArgumentError) { QDL::Wrap.process_pre_post_args(self.class, "C", TestQDL) { |x| x > 0 } }
    assert_raises(ArgumentError) { QDL::Wrap.process_pre_post_args(self.class, "C", TestQDL, ppos) }
    assert_raises(ArgumentError) { QDL::Wrap.process_pre_post_args(self.class, "C", TestQDL, :m1, ppos, 42) }
  end

  def test_pre_contract
    pos = QDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    def m5(x) return x; end
    QDL.pre TestQDL, :m5, pos
    assert_equal 3, m5(3)
    assert_raises(QDL::Contract::ContractError) { m5(-1) }
  end

  def test_post_contract
    neg = QDL::Contract::FlatContract.new("Negative") { |x| x < 0 }
    def m6(x) return 3; end
    QDL.post TestQDL, :m6, neg
    assert_raises(QDL::Contract::ContractError) { m6(42) }
  end

  def test_pre_post_contract
    pos = QDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    ppos = QDL::Contract::FlatContract.new("Positive") { |r, x| r > 0 }
    def m7(x) return x; end
    QDL.pre TestQDL, :m7, pos
    QDL.post TestQDL, :m7, ppos
    assert_equal 3, m7(3)
  end

  def test_and_contract
    pos = QDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    five = QDL::Contract::FlatContract.new("Five") { |x| x == 5 }
    gt = QDL::Contract::FlatContract.new("Greater Than 3") { |x| x > 3 }
    def m8(x) return x; end
    QDL.pre TestQDL, :m8, pos
    QDL.pre TestQDL, :m8, gt
    assert_equal 5, m8(5)
    assert_equal 4, m8(4)
    assert_raises(QDL::Contract::ContractError) { m8 3 }
    def m9(x) return x; end
    QDL.pre TestQDL, :m9, pos
    QDL.pre TestQDL, :m9, gt
    QDL.pre TestQDL, :m9, five
    assert_equal 5, m9(5)
    assert_raises(QDL::Contract::ContractError) { m9 4 }
    assert_raises(QDL::Contract::ContractError) { m9 3 }

    ppos = QDL::Contract::FlatContract.new("Positive") { |r, x| r > 0 }
    pfive = QDL::Contract::FlatContract.new("Five") { |r, x| r == 5 }
    pgt = QDL::Contract::FlatContract.new("Greater Than 3") { |r, x| r > 3 }
    def m10(x) return x; end
    QDL.post TestQDL, :m10, ppos
    QDL.post TestQDL, :m10, pgt
    assert_equal 5, m10(5)
    assert_equal 4, m10(4)
    assert_raises(QDL::Contract::ContractError) { m10 3 }
    def m11(x) return x; end
    QDL.post TestQDL, :m11, ppos
    QDL.post TestQDL, :m11, pgt
    QDL.post TestQDL, :m11, pfive
    assert_equal 5, m11(5)
    assert_raises(QDL::Contract::ContractError) { m11 4 }
    assert_raises(QDL::Contract::ContractError) { m11 3 }
  end

  def test_deferred_wrap
    pos = QDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    QDL.pre TestQDL, :m12, pos
    def m12(x) return x; end
    assert_equal 3, m12(3)
    assert_raises(QDL::Contract::ContractError) { m12(-1) }

    ppos = QDL::Contract::FlatContract.new("Positive") { |r, x| r > 0 }
    QDL.post TestQDL, :m13, ppos
    def m13(x) return x; end
    assert_equal 3, m13(3)
    assert_raises(QDL::Contract::ContractError) { m13(-1) }

    self.class.class_eval {
      pre(pos)
      def m14(x) return x; end
    }
    assert_equal 3, m14(3)
    assert_raises(QDL::Contract::ContractError) { m14(-1) }

    self.class.class_eval {
      pre { |x| x > 0 }
      def m15(x) return x; end
    }
    assert_equal 3, m15(3)
    assert_raises(QDL::Contract::ContractError) { m15(-1) }

    self.class.class_eval {
      pre { |x| x > 0 }
      post { |r, x| x > 0 }
      def m17(x) return x; end
    }
    assert_equal 3, m17(3)
    assert_raises(QDL::Contract::ContractError) { m17(-1) }

    self.class.class_eval {
      pre { |x| x > 0 }
      post { |r, x| x < 0 }
      def m18(x) return x; end
    }
    assert_raises(QDL::Contract::ContractError) { m18(-1) }

    self.class.class_eval {
      pre { |x| x > 0 }
      pre { |x| x < 5 }
      def m19(x) return x; end
    }
    assert_equal 3, m19(3)
    assert_raises(QDL::Contract::ContractError) { m19(6) }
    assert_raises(QDL::Contract::ContractError) { m19(-1) }

    assert_raises(RuntimeError) {
      self.class.class_eval <<-RUBY, __FILE__, __LINE__
  pre { |x| x > 0 }
  class Inner
    def m20(x)
      return x
    end
  end
RUBY
    }
  end

  def test_special_method_names
    self.class.class_eval {
      pre { |x| x > 0 }
      def [](x) return x end
    }
    assert_equal 3, self[3]
    assert_raises(QDL::Contract::ContractError) { self[-1] }
    self.class.class_eval {
      pre { |x| x > 0 }
      def foo?(x) return x end
    }
    assert_equal 3, foo?(3)
    assert_raises(QDL::Contract::ContractError) { foo?(-1) }
    self.class.class_eval {
      pre(:"bar!") { |x| x > 0 }
      def bar!(x) return x end
    }
    assert_equal 3, bar!(3)
    assert_raises(QDL::Contract::ContractError) { bar!(-1) }
  end

  def test_wrap_access_control
    def m20(x) return x; end
    def m21(x) return x; end
    def m22(x) return x; end
    self.class.class_eval { public(:m20) }
    self.class.class_eval { protected(:m21) }
    self.class.class_eval { private(:m22) }
    QDL::Wrap.wrap(TestQDL, :m20)
    QDL::Wrap.wrap(TestQDL, :m21)
    QDL::Wrap.wrap(TestQDL, :m22)
    assert (self.class.class_eval { public_method_defined? :m20 })
    assert (self.class.class_eval { protected_method_defined? :m21 })
    assert (self.class.class_eval { private_method_defined? :m22 })
  end

  def test_type_params
    self.class.class_eval "class TP1; extend QDL::Annotate; type_params [:t], :all? end"
    assert_equal [[:t], [:~], :all?], QDL::Wrap.get_type_params(TestQDL::TP1)
    self.class.class_eval "class TP2; extend QDL::Annotate; type_params([:t], nil) { |t| true } end"
    tp2 = QDL::Wrap.get_type_params(TestQDL::TP2)
    assert_equal [:t], tp2[0]
    assert_equal [:~], tp2[1]
    assert_raises(RuntimeError) { self.class.class_eval "class TP1; extend QDL::Annotate; type_params [:t], :all? end" }
    self.class.class_eval "class TP3; extend QDL::Annotate; type_params [:t, :u], :all? end"
    assert_equal [[:t, :u], [:~, :~], :all?], QDL::Wrap.get_type_params(TestQDL::TP3)

    self.class.class_eval "class TP4; extend QDL::Annotate; type_params [:t, :u, :v], :all?, variance: [:+, :-, :~] end"
    assert_equal [[:t, :u, :v], [:+, :-, :~], :all?], QDL::Wrap.get_type_params(TestQDL::TP4)
    assert_raises(RuntimeError) { self.class.class_eval "class TP5; extend QDL::Annotate; type_params([], :all?) { true } end" }
    assert_raises(RuntimeError) { self.class.class_eval "class TP6; extend QDL::Annotate; type_params [:t, :u], :all?, variance: [:+] end" }
    assert_raises(RuntimeError) { self.class.class_eval "class TP7; extend QDL::Annotate; type_params [:t, :u], :all?, variance: [:a, :b] end" }
    assert_raises(RuntimeError) { self.class.class_eval "class TP8; extend QDL::Annotate; type_params([:t], :all?) { |t| true } end" }
    assert_raises(RuntimeError) { self.class.class_eval "class TP8; extend QDL::Annotate; type_params [:t], 42 end" }
  end

  def test_wrap_new
    self.class.class_eval "class WrapB; def initialize(x); @x = x end; def get(); return @x end end"
    QDL.pre("TestQDL::WrapB", "self.new") { |x| x > 0 }
    assert_equal 3, TestQDL::WrapB.new(3).get
    assert_raises(QDL::Contract::ContractError) { TestQDL::WrapB.new(-3) }

    self.class.class_eval "class WrapC; extend QDL::Annotate; pre { |x| x > 0 }; def initialize(x); @x = x end; def get(); return @x end end"
    assert_equal 3, TestQDL::WrapC.new(3).get
    assert_raises(QDL::Contract::ContractError) { TestQDL::WrapC.new(-3) }

    self.class.class_eval "class WrapD; def get(); return @x end end"
    QDL.pre("TestQDL::WrapD", "self.new") { |x| x > 0 }
    self.class.class_eval "class WrapD; def initialize(x); @x = x end end"
    assert_equal 3, TestQDL::WrapD.new(3).get
    assert_raises(QDL::Contract::ContractError) { TestQDL::WrapD.new(-3) }

    skip "Can't defer contracts on new yet"
    QDL.
    pre("TestQDL::WrapE", "self.new") { |x| x > 0 }
    self.class.class_eval "class WrapE; def initialize(x); @x = x end end"
    assert (TestQDL::WrapE.new(3))
    assert_raises(QDL::Contract::ContractError) { TestQDL::WrapE.new(-3) }
  end

  def test_class_method
    pos = QDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    self.class.class_eval { def self.cm1(x) return x; end }
    QDL.pre TestQDL, "self.cm1", pos
    assert_equal 3, TestQDL.cm1(3)
    assert_raises(QDL::Contract::ContractError) { TestQDL.cm1(-1) }

    assert_raises(RuntimeError) { QDL.pre TestQDL, "TestQDL.cm1", pos }

    QDL.pre TestQDL, "self.cm2", pos
    self.class.class_eval { def self.cm2(x) return x; end }
    assert_equal 3, TestQDL.cm2(3)
    assert_raises(QDL::Contract::ContractError) { TestQDL.cm2(-1) }

    self.class.class_eval {
      pre { |x| x > 0 }
      def self.cm3(x) return x; end
    }
    assert_equal 3, TestQDL.cm3(3)
    assert_raises(QDL::Contract::ContractError) { TestQDL.cm3(-1) }
  end

  def test_cast
    obj1 = QDL.type_cast(3, QDL::Globals.types[:nil], force: true)
    assert (QDL::Globals.types[:nil].member? obj1)
    obj2 = QDL.type_cast(3, 'nil', force: true)
    assert (QDL::Globals.types[:nil].member? obj2)
    assert_raises(RuntimeError) { QDL.type_cast(3, QDL::Globals.types[:nil]) }
  end

  def test_pre_post_self
    self.class.class_eval {
      pre { |x| self.instance_of? TestQDL }
      post { |r, x| self.instance_of? TestQDL }
      def m23(x) return x; end
    }
    assert_equal 3, m23(3)
  end

  def test_nowrap
    QDL.pre(TestQDL, :nwrap1) { true }
    def nwrap1(x) return x; end
    assert(QDL::Wrap.wrapped?(TestQDL, :nwrap1))
    QDL.pre(TestQDL, :nwrap2, wrap: false) { true }
    def nwrap2(x) return x; end
    assert(not(QDL::Wrap.wrapped?(TestQDL, :nwrap2)))

    QDL.post(TestQDL, :nwrap3) { true }
    def nwrap3(x) return x; end
    assert(QDL::Wrap.wrapped?(TestQDL, :nwrap3))
    QDL.post(TestQDL, :nwrap4, wrap: false) { true }
    def nwrap4(x) return x; end
    assert(not(QDL::Wrap.wrapped?(TestQDL, :nwrap4)))

    QDL.type TestQDL, :nwrap5, "(Integer) -> Integer"
    def nwrap5(x) return x; end
    assert(QDL::Wrap.wrapped?(TestQDL, :nwrap5))
    QDL.type TestQDL, :nwrap6, "(Integer) -> Integer", wrap: false
    def nwrap6(x) return x; end
    assert(not(QDL::Wrap.wrapped?(TestQDL, :nwrap6)))

    self.class.class_eval {
      type "(Integer) -> Integer"
      def nwrap7(x) return x; end
    }
    assert(QDL::Wrap.wrapped?(TestQDL, :nwrap7))
    self.class.class_eval {
      type "(Integer) -> Integer", wrap: false
      def nwrap8(x) return x; end
    }
    assert(not(QDL::Wrap.wrapped?(TestQDL, :nwrap8)))
  end

  def test_var_type
    self.class.class_eval {
      var_type :@foo, "Integer"
      var_type :@@foo, "String"
      var_type :$foo, "Symbol"
    }
    assert_equal QDL::Globals.types[:integer], QDL::Globals.info.get(TestQDL, :@foo, :type)
    assert_equal QDL::Globals.types[:string], QDL::Globals.info.get(TestQDL, :@@foo, :type)
    assert_equal QDL::Globals.types[:symbol], QDL::Globals.info.get(QDL::Util::GLOBAL_NAME, :$foo, :type)
    assert_raises(RuntimeError) {
      self.class.class_eval { var_type :@foo, "String" }
    }
    assert_raises(RuntimeError) {
      self.class.class_eval { var_type :@@foo, "Integer" }
    }
    assert_raises(RuntimeError) {
      self.class.class_eval { var_type :Foo, "String" }
    }
    assert_raises(RuntimeError) {
      self.class.class_eval { var_type :$foo, "String" }
    }
  end

  def test_inconsistent
    self.class.class_eval {
      type "(Integer) -> Integer"
      pre { |x| true }
      def inconsistent1(y) return y; end
    }
  end

  def test_qdl_remove_type
    self.class.class_eval {
      type "() -> nil"
      def remove1() return 42; end
    }
    assert_raises(QDL::Type::TypeError) { remove1 }
    QDL.remove_type(self.class, :remove1)
    assert_equal 42, remove1 # shouldn't raise type error with contract removed
  end

  def test_version
    QDL.pre("TestQDL::TestVersion", "m1", version: Gem.ruby_version.to_s) { true }
    assert (QDL::Globals.info.has? "TestQDL::TestVersion", "m1", :pre)
    QDL.pre("TestQDL::TestVersion", "m2", version: Gem.ruby_version.bump.to_s) { true }
    assert !(QDL::Globals.info.has? "TestQDL::TestVersion", "m2", :pre)
    QDL.post("TestQDL::TestVersion", "m3", version: Gem.ruby_version.to_s) { true }
    assert (QDL::Globals.info.has? "TestQDL::TestVersion", "m3", :post)
    QDL.
    pre("TestQDL::TestVersion", "m4", version: Gem.ruby_version.bump.to_s) { true }
    assert !(QDL::Globals.info.has? "TestQDL::TestVersion", "m4", :post)
  end

  def test_pre_qdl_annotate_contract
    self.class.class_eval <<-RUBY, __FILE__, __LINE__
      class TestQDLAnnotate
        extend QDL::QDLAnnotate

        qdl_pre { |x| x > 0 }
        def m1(x) return x; end

        qdl_post { |x| x < 0 }
        def m2(x) return 3; end

        qdl_type '(Integer) -> Integer'
        def m3(x) return x; end
    end
RUBY
    assert_equal 3, TestQDLAnnotate.new.m1(3)
    assert_raises(QDL::Contract::ContractError) { TestQDLAnnotate.new.m1(-1) }
    assert_raises(QDL::Contract::ContractError) { TestQDLAnnotate.new.m2(42) }
    assert_raises(QDL::Type::TypeError) { TestQDLAnnotate.new.m3('one') }
  end

  class TC0
    def foo
      's'
    end

    def bar
      0
    end
  end

  class TC1 < TC0
    def foo
      's'
    end

    def bar
      0
    end
  end

  def test_wrap_inheritance
    QDL.type TC0, :foo, '() -> Integer', typecheck: :call
    QDL.type TC0, :bar, '() -> Integer', typecheck: :call
    QDL.type TC1, :foo, '() -> String', typecheck: :call
    QDL.type TC1, :bar, '() -> String', typecheck: :call
    assert_raises(QDL::Typecheck::StaticTypeError) { TC0.new.foo }
    assert_equal 0, TC0.new.bar
    assert_equal 's', TC1.new.foo
    assert_raises(QDL::Typecheck::StaticTypeError) { TC1.new.bar }
  end

end
