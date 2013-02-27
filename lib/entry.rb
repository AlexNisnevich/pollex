module Pollex
  class Entry
    include InstantiateWithAttrs

    attr_accessor :reflex, :description, :language, :source, :flag
  end
end
