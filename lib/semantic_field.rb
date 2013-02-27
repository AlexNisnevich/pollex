module Pollex
  class SemanticField
    include InstantiateWithAttrs

    attr_accessor :id, :name, :path, :count

    def self.all
      @semantic_fields ||= Pollex::Scraper.get("/category/", [
        [:id, 'td[1]/a/text()'],
        [:path, 'td[1]/a/@href'],
        [:name, 'td[2]/a/text()'],
        [:count, 'td[3]/text()']
      ]).map {|x| new(x) }
    end

    def self.count
      self.all.count
    end

    def self.first
      self.all.first
    end
  end
end
