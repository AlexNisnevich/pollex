module Pollex
  # helper instance methods
  class PollexObject
    # taken from https://github.com/neweryankee/nextbus/blob/master/lib/instantiate_with_attrs.rb
    def initialize(attrs={})
      super()
      attrs.each do |name, value|
        setter = "#{name.to_s}=".to_sym
        self.send(setter, value) if self.respond_to?(setter)
      end
      self
    end

    def inspect
      inspectables = self.class.inspectables
      if inspectables
        "#<#{self.class}:0x#{object_id.to_s(16)} " + inspectables.map {|i| "@#{i}=\"#{send(i)}\""}.join(' ') + ">"
      else
        super
      end
    end
  end

  # helper class methods
  module PollexClass
    attr_reader :inspectables

    def attr_inspector(*attrs)
      @inspectables = attrs
    end
  end
end
