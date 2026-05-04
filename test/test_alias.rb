require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'qdl'

class TestAlias < Minitest::Test
  extend QDL::Annotate

  def setup
    QDL.reset
  end

  def test_alias_lookup
    self.class.class_eval {
      qdl_alias :foobar1, :foobar
      qdl_alias :foobar2, :foobar
      qdl_alias :foobar3, :foobar2
      qdl_alias :foobar4, :foobar3
      qdl_alias :foobar5, :foobar2
    }
    assert_equal :foobar, QDL::Wrap.resolve_alias(TestAlias, :foobar)
    assert_equal :foobar, QDL::Wrap.resolve_alias(TestAlias, :foobar1)
    assert_equal :foobar, QDL::Wrap.resolve_alias(TestAlias, :foobar2)
    assert_equal :foobar, QDL::Wrap.resolve_alias(TestAlias, :foobar3)
    assert_equal :foobar, QDL::Wrap.resolve_alias(TestAlias, :foobar4)
    assert_equal :foobar, QDL::Wrap.resolve_alias(TestAlias, :foobar5)
  end

  def test_basic_alias_contract
    self.class.class_eval {
      pre { |x| x > 0 }
      def m1(x) return x; end
      alias_method :m2, :m1
    }
    assert_equal 3, m2(3)
    assert_raises(QDL::Contract::ContractError) { m2(-1) }
    self.class.class_eval { alias m3 m1 }
    assert_equal 3, m3(3)
    assert_raises(QDL::Contract::ContractError) { m3(-1) }
  end

  def test_existing_alias_contract
    self.class.class_eval {
      def m4(x) return x; end
      alias_method :m5, :m4
      qdl_alias :m5, :m4
      pre(:m4) { |x| x > 0 }
    }
    assert_equal 3, m5(3)
    assert_raises(QDL::Contract::ContractError) { m5(-1) }

    def m6(x) return x; end
    self.class.class_eval {
      alias m7 m6
      qdl_alias :m7, :m6
      pre(:m6) { |x| x > 0 }
    }
    assert_equal 3, m7(3)
    assert_raises(QDL::Contract::ContractError) { m7(-1) }

    def m8(x) return x; end
    self.class.class_eval {
      alias_method :m9, :m8
      qdl_alias :m9, :m8
      alias_method :m10, :m9
      qdl_alias :m10, :m9
      pre(:m8) { |x| x > 0 }
    }
    assert_equal 3, m10(3)
    assert_raises(QDL::Contract::ContractError) { m10(-1) }
  end

end
