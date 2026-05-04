require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'qdl'
require 'types/core'


class TestStringTypes < Minitest::Test
  extend QDL::Annotate

  def setup
    QDL.reset
    QDL::Config.instance.use_precise_string = true
    QDL.readd_comp_types
  end  

  def test_string_methods
    self.class.class_eval {

      type '(String) -> "hello"', typecheck: :append_fail1
      def append_fail_test1(x)
        "he" << x
      end

      type '("hello") -> Integer', typecheck: :append_fail2
      def append_fail_test2(x)
        takes_hello(x)
        x << 'blah'
        1
      end

      
      type "('he') -> 'hello'", typecheck: :now
      def append_test1(x)
        x << "llo"
      end

      type '(String) -> String', typecheck: :now
      def append_test2(x)
        "he" << x
      end

      type '("llo") -> String', typecheck: :now
      def append_test3(x)
        "he" << x
      end

      type :takes_hello, "('hello') -> Integer"

      type '("he") -> Integer', typecheck: :now
      def append_test4(y)
        takes_hello(y << "llo")
      end

      type '("hello") -> "Hello"', typecheck: :now
      def capitalize_test1(x)
        x.capitalize
      end

      type '("hello") -> "Hello"', typecheck: :now
      def capitalize_test2(x)
        x.capitalize!
      end

      type '("hello") -> "o"', typecheck: :now
      def access_test1(x)
        x[4]
      end

      type '("he") -> "hello"', typecheck: :now
      def concat_test1(x)
        x + "llo"
      end

      type '("hello") -> 5', typecheck: :now
      def size_test1(x)
        x.size
      end

      type '(String) -> Integer', typecheck: :now
      def size_test2(x)
        x.size
      end

      type '(:world) -> "hello, world!"', typecheck: :now
      def interp_test1(y)
        "hello, #{y}!"
      end

      type '(Symbol) -> String', typecheck: :now
      def interp_test2(y)
        "hello, #{y}!"
      end

      type '("hi") -> "bye"', typecheck: :now
      def replace_test1(x)
        x.replace "bye"
        x
      end
    }
    assert_raises(QDL::Typecheck::StaticTypeError) { QDL.do_typecheck :append_fail1 }
    assert_raises(QDL::Typecheck::StaticTypeError) { QDL.do_typecheck :append_fail2 }
  end
end
