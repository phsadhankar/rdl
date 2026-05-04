require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'qdl'

class TestWrap < Minitest::Test
  extend QDL::Annotate

  def setup
    QDL.reset
  end

  class C
    def foo_public(x)
      foo(x)
    end

    private

    def foo(x)
      x + 1
    end
  end

  def test_private_wrap
    QDL.type C, :foo, '(Integer) -> Integer'
    c = C.new

    assert_raises QDL::Type::TypeError do
      c.foo_public("1")
    end
  end

  class D
    def foo_public(x)
      foo(x)
    end

    protected

    def foo(x)
      x + 1
    end
  end

  def test_protected_wrap
    QDL.type D, :foo, '(Integer) -> Integer'
    d = D.new

    assert_raises QDL::Type::TypeError do
      d.foo_public("1")
    end
  end
end
