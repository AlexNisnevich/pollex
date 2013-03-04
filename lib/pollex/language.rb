module Pollex
  class Language < PollexObject
    extend PollexClass

    attr_accessor :name, :path
    attr_writer :code, :count
    attr_inspector :name, :code, :count, :path

    def entries
      @entries ||= Scraper.instance.get_all(Entry, @path, [
        [:reflex, 'td[2]/text()'],
        [:description, 'td[3]/text()'],
        [:language_name, nil, lambda {|x| @name}],
        [:language_path, nil, lambda {|x| @path}],
        [:source_code, 'td[4]/a/text()'],
        [:source_path, 'td[4]/a/@href'],
        [:flag, "td[3]/span[@class='flag']/text()"]
     ])
    end

    def code
      @code ||= @path.split('/')[2].upcase
    end

    def count
      @count ||= Scraper.instance.get(@path, [
        [:count, "p[@class='count']/text()", lambda {|x| x.split(' ').first}]
      ])[:count]
    end

    def self.all
      @languages ||= Scraper.instance.get_all(Language, "/language/", [
        [:name, 'td[2]/a/text()'],
        [:path, 'td[1]/a/@href'],
        [:code, 'td[1]/a/text()'],
        [:count, 'td[3]/text()']
      ])
    end

    def self.count
      self.all.count
    end

    def self.find(name)
      Scraper.instance.get_all(Language, "/search/?field=language&query=#{name}", [
        [:name, 'td[1]/a/text()'],
        [:path, 'td[1]/a/@href']
      ])
    end
  end
end
