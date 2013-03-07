module Pollex
  # A semantic class containing a list of Pollex reconstructed protoforms.
  class SemanticField < PollexObject
    extend PollexClass

    attr_accessor :id, :name, :path, :count
    attr_inspector :id, :name, :count, :path

    # Returns all Reconstructions corresponding to this SemanticField
    # @return [Array<Reconstruction>] array of Reconstructions corresponding to this SemanticField
    def reconstructions
      @reconstructions ||= Scraper.instance.get_all(Reconstruction, @path, [
        [:path, 'td[1]/a/@href'],
        [:protoform, 'td[1]/a/text()'],
        [:description, 'td[2]/text()'],
        [:semantic_field, nil, lambda {|x| self}]
      ])
    end

    # Returns all SemanticFields in Pollex.
    # @return [Array<SemanticField>] array of SemanticFields in Pollex
    def self.all
      @semantic_fields ||= Scraper.instance.get_all(SemanticField, "/category/", [
        [:id, 'td[1]/a/text()'],
        [:path, 'td[1]/a/@href'],
        [:name, 'td[2]/a/text()'],
        [:count, 'td[3]/text()']
      ])
    end

    # Counts the number of SemanticField within Pollex
    # @return [Integer] number of SemanticField in Pollex
    def self.count
      self.all.count
    end

    # Looks up all SemanticFields matching a given name.
    # @note Pollex has no built-in search for SemanticFields, so this method is
    #   simply a filter over SemanticField.all.
    # @param name [String] term to search for
    # @return [Array<SemanticField>] array of SemanticFields matching the search term
    def self.find(name)
      self.all.select { |sf| sf.name.downcase.include?(name.downcase) }
    end
  end
end
