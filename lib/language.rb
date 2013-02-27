module Pollex
  class Language
    include InstantiateWithAttrs

    attr_accessor :name, :path

    def entries
      @entries ||= Scraper.get_all(Entry, @path, [
        [:reflex, 'td[2]/text()'],
        [:description, 'td[3]/text()'],
        [:source_name, 'td[4]/a/text()'],
        [:source_path, 'td[4]/a/@href'],
        [:flag, "td[3]/span[@class='flag']/text()"]
     ])
    end
  end
end
