share_as :DefinesConstants do
  def define_class(class_name, base = Object, &block)
    class_name = class_name.to_s.camelize
    klass = Class.new(base)
    define_constant(class_name, klass)
    klass.class_eval(&block) if block_given?
    klass
  end

  def define_constant(name, value)
    Object.const_set(name, value)
    @defined_constants << name
    value
  end

  before { @defined_constants = [] }

  after do
    @defined_constants.each do |class_name|
      Object.send(:remove_const, class_name)
    end
  end
end

