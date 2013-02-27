module Pollex
  class Source
    include InstantiateWithAttrs

    attr_accessor :code, :path, :name, :reference, :count

    def entries
      @entries ||= Scraper.get_all(Entry, @path, [
        [:language_name, 'td[1]/a/text()'],
        [:language_path, 'td[1]/a/@href'],
        [:reflex, 'td[2]/text()'],
        [:description, 'td[3]/text()'],
        [:flag, "td[3]/span[@class='flag']/text()"]
     ])
    end

    def self.all
      @sources ||= Scraper.get_all(Source, "/source/", [
        [:code, 'td[1]/a/text()'],
        [:path, 'td[1]/a/@href'],
        [:name, 'td[2]/a/text()'],
        [:count, 'td[3]/text()'],
        [:reference, 'td[4]/text()']
      ])
    end
  end
end
