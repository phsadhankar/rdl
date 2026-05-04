require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'qdl'

class TestQDLType < Minitest::Test
  extend QDL::Annotate

  def setup
    QDL.reset
  end

  def test_single_type_contract
    def m1(x) return x; end
    QDL.type TestQDLType, :m1, "(Integer) -> Integer"
    assert_equal 5, m1(5)
    assert_raises(QDL::Type::TypeError) { m1("foo") }

    self.class.class_eval {
      type :m2, "(Integer) -> Integer"
      def m2(x) return x; end
    }
    assert_equal 5, m2(5)
    assert_raises(QDL::Type::TypeError) { m2("foo") }

    self.class.class_eval {
      type "(Integer) -> Integer"
      def m3(x) return x; end
    }
    assert_equal 5, m3(5)
    assert_raises(QDL::Type::TypeError) { m3("foo") }
  end

  def test_intersection_type_contract
    self.class.class_eval {
      type "(Integer) -> Integer"
      type "(String) -> String"
      def m4(x) return x; end
    }
    assert_equal 5, m4(5)
    assert_equal "foo", m4("foo")
    assert_raises(QDL::Type::TypeError) { m4(:foo) }

    self.class.class_eval {
      type "(Integer) -> Integer"
      type "(String) -> String"
      def m5(x) return 42; end
    }
    assert_equal 42, m5(3)
    assert_raises(QDL::Type::TypeError) { m5("foo") }

    self.class.class_eval {
      type "(Integer) -> Integer"
      type "(Integer) -> String"
      def m6(x) if x > 10 then :oops elsif x > 5 then x else "small" end end
    }
    assert_equal 8, m6(8)
    assert_equal "small", m6(1)
    assert_raises(QDL::Type::TypeError) { m6(42) }
  end

  def test_fixnum_type_contract
    self.class.class_eval {
      type "(0) -> Integer"
      def m7(x) return x; end
    }
    assert_equal 0, m7(0)
    assert_raises(QDL::Type::TypeError) { m7(1) }
  end

  def test_wrap_new_inherited
    self.class.class_eval "class NI_A; def initialize(x); @x = x; end; end; class NI_B < NI_A; end"
    QDL.type "TestQDLType::NI_A", "self.new", "(Integer) -> TestQDLType::NI_A"
    assert (TestQDLType::NI_B.new(3))
    assert_raises(QDL::Type::TypeError) { TestQDLType::NI_B.new("3") }
  end

  def test_version
    QDL.type "TestQDLType::TestVersion", "m1", "() -> nil", version: Gem.ruby_version.to_s
    assert (QDL::Globals.info.has? "TestQDLType::TestVersion", "m1", :type)
    QDL.type "TestQDLType::TestVersion", "m2", "() -> nil", version: Gem.ruby_version.bump.to_s
    assert !(QDL::Globals.info.has? "TestQDLType::TestVersion", "m2", :type)
  end

  def test_wrap_subclass_method
    self.class.class_eval "class NI_C; def foo; :A; end; end"
    self.class.class_eval "class NI_D < NI_C; def foo; :B; end; end"
    QDL.type 'TestQDLType::NI_C', :foo, '() -> :A'
    QDL.type 'TestQDLType::NI_D', :foo, '() -> :A'
    assert TestQDLType::NI_C.new.foo
    assert_raises(QDL::Type::TypeError) { TestQDLType::NI_D.new.foo}
  end
end
