share_as :DefinesConstants do
  def define_constant(class_name, base = Object, &block)
    class_name = class_name.to_s.camelize

    klass = Class.new(base)
    Object.const_set(class_name, klass)

    klass.class_eval(&block) if block_given?

    @defined_constants << class_name

    klass
  end

  before { @defined_constants = [] }

  after do
    @defined_constants.each do |class_name|
      Object.send(:remove_const, class_name)
    end
  end
end

