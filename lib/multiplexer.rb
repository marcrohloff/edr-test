class Multiplexer
  attr_reader :instances

  def initialize(*instances)
    @instances = instances
  end

  def method_missing(method_name, ...)
    if all_instances_respond_to?(method_name)
      instances.map do |instance|
        instance.send(method_name, ...)
      end

    elsif some_instances_respond_to?(method_name)
      raise(NoMethodError, "method '#{method_name}'not defined for all instances")

    else
      super

    end
  end

  def respond_to?(method_name, ...)
    super || all_instances_respond_to?(method_name)
  end

  private

  def all_instances_respond_to?(method_name)
    # only allow public methods
    instances.all? { it.respond_to?(method_name) }
  end

  def some_instances_respond_to?(method_name)
    # only allow public methods
    instances.some? { it.respond_to?(method_name) }
  end

end
