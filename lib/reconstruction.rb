module Pollex
  class Reconstruction
    include InstantiateWithAttrs

    attr_accessor :path, :protoform, :description

    def entries
      @entries ||= Scraper.get_all(Entry, @path, [
        [:reflex, 'td[2]/text()'],
        [:description, 'td[3]/text()'],
        [:language_name, 'td[1]/a/text()'],
        [:language_path, 'td[1]/a/@href'],
        [:source_code, 'td[4]/a/text()'],
        [:source_path, 'td[4]/a/@href'],
        [:reconstruction_name, nil, lambda {|x| @protoform}],
        [:reconstruction_path, nil, lambda {|x| @path}],
        [:flag, "td[3]/span[@class='flag']/text()"]
     ], 1)
    end

    def description
      @description ||= Scraper.get(@path, [
        [:description, "table[1]/tr[1]/td/text()"]
      ])[:description]
    end

    def level
      unless @level
        level_parts = Scraper.get(@path, [
          [:code, "table[1]/tr[2]/td/a/text()", lambda {|x| x.split(':')[0]}],
          [:path, "table[1]/tr[2]/td/a/@href"]
        ])
        @level = Level.new(:code => level_parts[:code], :path => level_parts[:path])
      end
      @level
    end

    def notes
      @notes ||= Scraper.get(@path, [
        [:notes, "table[1]/tr[3]/td/p/text()"]
      ])[:notes]
    end

    def count
      @count ||= Scraper.get(@path, [
        [:count, "p[@class='count']/text()", lambda {|x| x.split(' ').first}]
      ])[:count]
    end

    def self.all
      @sources ||= Scraper.get_all(Reconstruction, "/entry/", [
        [:path, 'td[2]/a/@href'],
        [:protoform, 'td[2]/a/text()'],
        [:description, 'td[3]/text()']
      ])
    end

    def self.count
      @count ||= Scraper.get("/entry/", [
        [:count, "p[@class='count']/text()", lambda {|x| x.split(' ').first}]
      ])[:count]
    end

    def self.find(name)
      Scraper.get_all(Reconstruction, "/search/?field=protoform&query=#{name}", [
        [:path, 'td[2]/a/@href'],
        [:protoform, 'td[2]/a/text()'],
        [:description, 'td[3]/text()']
      ])
    end
  end
end
