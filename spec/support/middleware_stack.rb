class MiddlewareStack
  def initialize
    @middlewares = []
  end

  def use(klass, *args)
    @middlewares << klass.new('fake_app', *args)
  end

  def include?(klass)
    @middlewares.any? { |middleware| klass === middleware }
  end
end
