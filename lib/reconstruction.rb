module Pollex
  class Reconstruction
    include InstantiateWithAttrs

    attr_accessor :path, :reconstruction, :description

    def entries
      @entries ||= Scraper.get_all(Entry, @path, [
        [:reflex, 'td[2]/text()'],
        [:description, 'td[3]/text()'],
        [:language_name, 'td[1]/a/text()'],
        [:language_path, 'td[1]/a/@href'],
        [:source_name, 'td[4]/a/text()'],
        [:source_path, 'td[4]/a/@href'],
        [:flag, "td[3]/span[@class='flag']/text()"]
     ], 1)
    end

    def self.get_from_path(path)
      new(:path => path)
    end
  end
end
