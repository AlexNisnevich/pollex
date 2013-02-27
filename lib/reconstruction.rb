module Pollex
  class Reconstruction
    include InstantiateWithAttrs

    attr_accessor :path, :reconstruction, :description

    def entries
      @entries ||= Pollex::Scraper.get(@path, [
        [:reflex, 'td[2]/text()'],
        [:description, 'td[3]/text()'],
        [:language, 'td[1]/a/text()'],
        [:source, 'td[4]/a/text()'],
        [:flag, "td[3]/span[@class='flag']/text()"]
     ], 1).map {|x| Entry.new(x) }
    end
  end
end
