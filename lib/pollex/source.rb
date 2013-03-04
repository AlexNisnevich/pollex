module Pollex
  class Source < PollexObject
    extend PollexClass

    attr_accessor :code, :path
    attr_writer :name, :reference, :count
    attr_inspector :code, :name, :reference, :count, :path

    def entries
      @entries ||= Scraper.instance.get_all(Entry, @path, [
        [:language_name, 'td[1]/a/text()'],
        [:language_path, 'td[1]/a/@href'],
        [:reflex, 'td[2]/text()'],
        [:description, 'td[3]/text()'],
        [:flag, "td[3]/span[@class='flag']/text()"]
     ])
    end

    def name
      @name ||= Scraper.instance.get(@path, [
        [:name, 'h1/text()', lambda {|x| x.match('Entries from (.*) in Pollex-Online')[1]}]
      ])[:name]
    end

    def reference
      @reference ||= Scraper.instance.get(@path, [
        [:name, "p[@class='ref']/text()"]
      ])[:name]
    end

    def count
      @count ||= @entries.count
    end

    def self.all
      @sources ||= Scraper.instance.get_all(Source, "/source/", [
        [:code, 'td[1]/a/text()'],
        [:path, 'td[1]/a/@href'],
        [:name, 'td[2]/a/text()'],
        [:count, 'td[3]/text()'],
        [:reference, 'td[4]/text()']
      ])
    end
  end
end
