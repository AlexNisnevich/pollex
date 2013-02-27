module Pollex
  class Language
    include InstantiateWithAttrs

    attr_accessor :name, :path, :code, :count

    def entries
      @entries ||= Scraper.get_all(Entry, @path, [
        [:reflex, 'td[2]/text()'],
        [:description, 'td[3]/text()'],
        [:source_name, 'td[4]/a/text()'],
        [:source_path, 'td[4]/a/@href'],
        [:flag, "td[3]/span[@class='flag']/text()"]
     ])
    end

    def code
      @code ||= @path.split('/')[2].upcase
    end

    def count
      @count ||= Scraper.get(@path, [
        [:count, "p[@class='count']/text()", lambda {|x| x.split(' ').first}]
      ])[:count]
    end

    def self.all
      @sources ||= Scraper.get_all(Language, "/language/", [
        [:code, 'td[1]/a/text()'],
        [:path, 'td[1]/a/@href'],
        [:name, 'td[2]/a/text()'],
        [:count, 'td[3]/text()']
      ])
    end

    def self.find(name)
      Scraper.get_all(Language, "/search/?field=language&query=#{name}", [
        [:name, 'td[1]/a/text()'],
        [:path, 'td[1]/a/@href']
      ])
    end
  end
end
