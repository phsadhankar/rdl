# Defines QDL methods that do nothing

module QDL
end

module QDL::Annotate
  def pre(*args); end
  def post(*args); end
  def type(*args); end
  def var_type(*args); end
  def attr_accessor_type(*args)
    args.each_slice(2) { |name, typ| attr_accessor name }
    nil
  end

  def attr_reader_type(*args)
    args.each_slice(2) { |name, typ| attr_reader name }
    nil
  end

  alias_method :attr_type, :attr_reader_type

  def attr_writer_type(*args)
    args.each_slice(2) { |name, typ| attr_writer name }
    nil
  end

  def qdl_alias(*args); end
  def type_params(*args); end
end

module QDL::QDLAnnotate
  define_method :qdl_pre, QDL::Annotate.instance_method(:pre)
  define_method :qdl_post, QDL::Annotate.instance_method(:post)
  define_method :qdl_type, QDL::Annotate.instance_method(:type)
  define_method :qdl_var_type, QDL::Annotate.instance_method(:var_type)
  define_method :qdl_alias, QDL::Annotate.instance_method(:qdl_alias)
  define_method :qdl_type_params, QDL::Annotate.instance_method(:type_params)
  define_method :qdl_attr_accessor_type, QDL::Annotate.instance_method(:attr_accessor_type) # note in disable these don't call var_type
  define_method :qdl_attr_reader_type, QDL::Annotate.instance_method(:attr_reader_type)
  define_method :qdl_attr_type, QDL::Annotate.instance_method(:attr_type)
  define_method :qdl_attr_writer_type, QDL::Annotate.instance_method(:attr_writer_type)
end


module QDL
  extend QDL::Annotate
  def self.type_alias(*args); end
  def self.nowrap(*args); end
  def self.do_typecheck(*args); end
  def self.at(*args); end
  def self.note_type(*args); end
  def self.remove_type(*args); end
  def self.instantiate!(*args); self; end
  def self.deinstantiate!(*args); self; end
  def self.type_cast(*args); self; end
  def self.query(*args); end
end

def QDL.config(*args); end
