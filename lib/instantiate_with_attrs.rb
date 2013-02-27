# taken from https://github.com/neweryankee/nextbus/blob/master/lib/instantiate_with_attrs.rb
module InstantiateWithAttrs
  def initialize(attrs={})
    super()
    attrs.each do |name, value|
      setter = "#{name.to_s}=".to_sym
      self.send(setter, value) if self.respond_to?(setter)
    end
    self
  end
end
