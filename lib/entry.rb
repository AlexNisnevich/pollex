module Pollex
  class Entry
    include InstantiateWithAttrs

    attr_accessor :reflex, :description, :language, :language_name, :language_path, :source_code, :source_path, :flag

    def language
      @language ||= Language.new(:name => @language_name, :path => @language_path)
    end

    def source
      @source ||= Source.new(:code => @source_code, :path => @source_path)
    end
  end
end
