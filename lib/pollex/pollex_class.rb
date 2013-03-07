module Pollex
  # Superclass for Pollex objects providing helper instance methods.
  class PollexObject
    # Initializes objects with a hash of attributes.
    # @see https://github.com/neweryankee/nextbus/blob/master/lib/instantiate_with_attrs.rb
    # @author neweryankee
    def initialize(attrs={})
      super()
      attrs.each do |name, value|
        setter = "#{name.to_s}=".to_sym
        self.send(setter, value) if self.respond_to?(setter)
      end
      self
    end

    # Overrides <tt>Object#inspect</tt> to only show the attributes defined
    # by <tt>PollexClass#attr_inspector</tt>.
    # @see PollexClass#attr_inspector
    def inspect
      inspectables = self.class.inspectables
      if inspectables
        "#<#{self.class}:0x#{object_id.to_s(16)} " + inspectables.map {|i| "@#{i}=\"#{send(i) rescue nil}\""}.join(' ') + ">"
      else
        super
      end
    end
  end

  # Provides helper class methods for Pollex classes.
  module PollexClass
    attr_reader :inspectables

    # Defines the list of attributes whose values are displayed by <tt>PollexObject#inspect</tt>.
    # @param *attrs [Array<Symbol>] array of attribute labels
    # @see PollexObject#inspect
    def attr_inspector(*attrs)
      @inspectables = attrs
    end
  end
end
