module Pollex
  class SemanticField
    include InstantiateWithAttrs

    attr_accessor :id, :name, :path, :count

    def reconstructions
      @reconstructions ||= Scraper.get_all(Reconstruction, @path, [
        [:path, 'td[1]/a/@href'],
        [:protoform, 'td[1]/a/text()'],
        [:description, 'td[2]/text()']
      ])
    end

    def self.all
      @semantic_fields ||= Scraper.get_all(SemanticField, "/category/", [
        [:id, 'td[1]/a/text()'],
        [:path, 'td[1]/a/@href'],
        [:name, 'td[2]/a/text()'],
        [:count, 'td[3]/text()']
      ])
    end

    def self.count
      self.all.count
    end
  end
end
