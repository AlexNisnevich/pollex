module Pollex
  # A semantic class containing a list of Pollex reconstructed protoforms.
  class SemanticField < PollexObject
    extend PollexClass

    attr_accessor :code, :name, :path, :count
    attr_inspector :id, :code, :name, :count, :path

    # @return [Integer] Pollex's internal ID for this SemanticField
    def id
      @path.split('/').last.to_i
    end

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
        [:code, 'td[1]/a/text()'],
        [:path, 'td[1]/a/@href'],
        [:name, 'td[2]/a/text()'],
        [:count, 'td[3]/text()']
      ])
    end

    # Counts the number of SemanticFields within Pollex
    # @return [Integer] number of SemanticFields in Pollex
    def self.count
      self.all.count
    end

    # Looks up SemanticField corresponding to a given internal ID
    # @param id [Integer] ID of SemanticField to find
    # @return [SemanticField]
    def self.find(id)
      self.all.select { |sf| sf.id == id }
    end

    # Looks up all SemanticFields matching a given name.
    # @note Pollex has no built-in search for SemanticFields, so this method is
    #   simply a filter over SemanticField.all.
    # @param name [String] term to search for
    # @return [Array<SemanticField>] array of SemanticFields matching the search term
    def self.find_by_name(name)
      self.all.select { |sf| sf.name.downcase.include?(name.downcase) }
    end
  end
end
