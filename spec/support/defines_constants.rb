module DefinesConstants
  def self.included(example_group)
    super
    example_group.class_eval do
      before { @defined_constants = [] }
      after { undefine_constants }
    end
  end

  def define_class(class_name, base = Object, &block)
    class_name = class_name.to_s.camelize
    klass = Class.new(base)
    define_constant(class_name, klass)
    klass.class_eval(&block) if block_given?
    klass
  end

  def define_constant(path, value)
    parse_constant(path) do |parent, name|
      parent.const_set(name, value)
    end

    @defined_constants << path
    value
  end

  def parse_constant(path)
    parent_names = path.split('::')
    name = parent_names.pop
    parent = parent_names.inject(Object) do |ref, child_name|
      ref.const_get(child_name)
    end
    yield(parent, name)
  end

  def undefine_constants
    @defined_constants.reverse.each do |path|
      parse_constant(path) do |parent, name|
        parent.send(:remove_const, name)
      end
    end
  end
end

