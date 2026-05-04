require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'qdl'
QDL.reset

class TestGeneric < Minitest::Test
  extend QDL::Annotate

  # Make two classes that wrap Array and Hash, so we don't mess with their
  # implementations in test case evaluation.
  class A
    def initialize(a); @a = a end
    def all?(&blk)
      @a.all?(&blk)
    end
  end

  class H
    def initialize(h); @h = h end
    def all?(&blk)
      @h.all? { |x, y| blk.call(x, y) } # have to do extra wrap to avoid splat issues
    end
  end

  class B
    extend QDL::Annotate
    # class for checking other variance annotations
    def m1(x) # type annotation
      nil
    end
    def m2(x) # no type annotation
      nil
    end
  end

  class C
    def m1() return self; end
    def m2() return C.new; end
    def m3() return Object.new; end
  end

  class D < C
  end



  def setup
    QDL.reset
    QDL.type_params A, [:t], :all?
    QDL.type_params H, [:k, :v], :all?
    QDL.type_params(B, [:a, :b], nil, variance: [:+, :-]) { |a, b| true }
    QDL.type B, :m1, "(a) -> nil"
    QDL.type C, :m1, "() -> self"
    QDL.type C, :m2, "() -> self"
    QDL.type C, :m3, "() -> self"
    @ta = QDL::Type::NominalType.new "TestGeneric::A"
    @th = QDL::Type::NominalType.new "TestGeneric::H"
    @tas = QDL::Type::GenericType.new(@ta, QDL::Globals.types[:string])
    @tao = QDL::Type::GenericType.new(@ta, QDL::Globals.types[:object])
    @taas = QDL::Type::GenericType.new(@ta, @tas)
    @taao = QDL::Type::GenericType.new(@ta, @tao)
    @thss = QDL::Type::GenericType.new(@th, QDL::Globals.types[:string], QDL::Globals.types[:string])
    @thoo = QDL::Type::GenericType.new(@th, QDL::Globals.types[:object], QDL::Globals.types[:object])
    @thsf = QDL::Type::GenericType.new(@th, QDL::Globals.types[:string], QDL::Globals.types[:integer])
    @tb = QDL::Type::NominalType.new "TestGeneric::B"
  end

  def test_le
    # Check invariance for A and H
    assert (@tas <= @tas)
    assert (@tao <= @tao)
    assert (@taas <= @taas)
    assert (@thss <= @thss)
    assert (@thoo <= @thoo)
    assert (not (@tas <= @tao))
    assert (not (@tao <= @tas))
    assert (not (@thss <= @thoo))
    assert (not (@thoo <= @thss))

    # Check "raw" class subtyping is forbidden
    assert (not (@ta <= @tas))
    assert (not (@tas <= @ta))
    assert (not (@ta <= @taas))
    assert (not (@taas <= @ta))
    assert (not (@th <= @thss))
    assert (not (@thss <= @th))

    # Check co- and contravariance using B
    tbss = QDL::Type::GenericType.new(@tb, QDL::Globals.types[:string], QDL::Globals.types[:string])
    tbso = QDL::Type::GenericType.new(@tb, QDL::Globals.types[:string], QDL::Globals.types[:object])
    tbos = QDL::Type::GenericType.new(@tb, QDL::Globals.types[:object], QDL::Globals.types[:string])
    tboo = QDL::Type::GenericType.new(@tb, QDL::Globals.types[:object], QDL::Globals.types[:object])
    assert (tbss <= tbss)
    assert (not (tbss <= tbso))
    assert (tbss <= tbos)
    assert (not (tbss <= tboo))
    assert (tbso <= tbss)
    assert (tbso <= tbso)
    assert (tbso <= tbos)
    assert (tbso <= tboo)
    assert (not (tbos <= tbss))
    assert (not (tbos <= tbso))
    assert (tbos <= tbos)
    assert (not (tbos <= tboo))
    assert (not (tboo <= tbss))
    assert (not (tboo <= tbso))
    assert (tboo <= tbos)
    assert (tboo <= tboo)
  end

  def test_le_structural
    tbss = QDL::Type::GenericType.new(@tb, QDL::Globals.types[:string], QDL::Globals.types[:string])
    tma = QDL::Type::MethodType.new([], nil, QDL::Globals.types[:nil])
    tmb = QDL::Type::MethodType.new([QDL::Globals.types[:string]], nil, QDL::Globals.types[:nil])
    tmc = QDL::Type::MethodType.new([QDL::Globals.types[:integer]], nil, QDL::Globals.types[:nil])
    ts1 = QDL::Type::StructuralType.new(m2: tma)
    assert (tbss <= ts1)
    ts2 = QDL::Type::StructuralType.new(m1: tmb)
    assert (tbss <= ts2)
    ts3 = QDL::Type::StructuralType.new(m1: tmb, m2: tma)
    assert (tbss <= ts3)
    ts4 = QDL::Type::StructuralType.new(m1: tmc, m2: tma)
    assert (not (tbss <= ts4))
    ts5 = QDL::Type::StructuralType.new(m1: tmb, m2: tmc)
    assert (tbss <= ts5)
  end

  def test_self_type
    c = C.new
    assert(c.m1)
    assert(c.m2)
    assert_raises(QDL::Type::TypeError) { c.m3 }
    assert(D.new.m1)
  end

  def test_member
    # member? should only check the base types
    assert (@ta.member?(A.new([1, 2, 3])))
    assert (@ta.member?(A.new([])))
    assert (@ta.member?(A.new(["a", "b", "c"])))
    assert (@tas.member?(A.new([1, 2, 3])))
    assert (@tas.member?(A.new([])))
    assert (@tas.member?(A.new(["a", "b", "c"])))
    assert (@taas.member?(A.new([1, 2, 3])))
    assert (@taas.member?(A.new([])))
    assert (@taas.member?(A.new(["a", "b", "c"])))
  end

  def test_instantiate
    assert_raises(RuntimeError) { QDL.instantiate!(Object.new, QDL::Globals.types[:string]) }

    # Array<String>
    assert (QDL.instantiate!(A.new([]), 'String'))
    assert (QDL.instantiate!(A.new(["a", "b", "c"]), QDL::Globals.types[:string], check: true))
    assert (QDL.instantiate!(A.new(["a", "b", "c"]), 'String', check: true))
    assert_raises(QDL::Type::TypeError) { QDL.instantiate!(A.new([1, 2, 3]), 'String', check: true) }
    assert (QDL.instantiate!(A.new([1, 2, 3]), 'String', check: false))

    # Array<Object>
    assert (QDL.instantiate!(A.new([]), 'Object', check: true))
    assert (QDL.instantiate!(A.new(["a", "b", "c"]), QDL::Globals.types[:object], check: true))
    assert (QDL.instantiate!(A.new(["a", "b", "c"]), 'Object', check: true))
    assert (QDL.instantiate!(A.new([1, 2, 3]), 'Object', check: true))

    # Hash<String, Integer>
    assert (QDL.instantiate!(H.new({}), 'String', 'Integer', check: true))
    assert (QDL.instantiate!(H.new({"one"=>1, "two"=>2}), 'String', 'Integer', check: true))
    assert_raises(QDL::Type::TypeError) {
      QDL.instantiate!(H.new(one: 1, two: 2), 'String', 'Integer', check: true)
    }
    assert (QDL.instantiate!(H.new(one: 1, two: 2), 'String', 'Integer', check: false))
    assert_raises(QDL::Type::TypeError){
      QDL.instantiate!(H.new({"one"=>:one, "two"=>:two}), 'String', 'Integer', check: true)
    }

    # Hash<Object, Object>
    assert (QDL.instantiate!(H.new({}), 'Object', 'Object', check: true))
    assert (QDL.instantiate!(H.new({"one"=>1, "two"=>2}), 'Object', 'Object', check: true))
    assert (QDL.instantiate!(H.new(one: 1, two: 2), 'Object', 'Object', check: true))
    assert (QDL.instantiate!(H.new({"one"=>:one, "two"=>:two}), 'Object', 'Object', check: true))

    # A<A<String>>
    assert (QDL.instantiate!(A.new([QDL.instantiate!(A.new(["a", "b"]), 'String', check: true),
                                    QDL.instantiate!(A.new(["c"]), 'String', check: true)]), 'TestGeneric::A<String>', check: true))
    assert_raises(QDL::Type::TypeError) {
      # Must instantiate all members
      QDL.instantiate!(A.new([QDL.instantiate!(A.new(["a", "b"]), 'String', check: true), A.new([])]), 'TestGeneric::A<String>', check: true)
    }
    assert_raises(QDL::Type::TypeError) {
      # All members must be of same type
      QDL.instantiate!(A.new([QDL.instantiate!(A.new(["a", "b"]), 'String', check: true), "A"]), 'TestGeneric::A<String>', check: true)
    }
    assert_raises(QDL::Type::TypeError) {
      # All members must be instantiated and of same type
      QDL.instantiate!(A.new([QDL.instantiate!(A.new(["a", "b"]), 'String', check: true),
                              QDL.instantiate!(H.new({a: 1, b: 2}), 'Object', 'Object', check: true)]), 'TestGeneric::A<String>', check: true)
    }
  end

end
