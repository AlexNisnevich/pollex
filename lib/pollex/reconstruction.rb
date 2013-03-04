module Pollex
  class Reconstruction < PollexObject
    extend PollexClass

    attr_accessor :path, :protoform, :description, :semantic_field
    attr_inspector :protoform, :description, :path

    def entries
      @entries ||= Scraper.instance.get_all(Entry, @path, [
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
      @description ||= Scraper.instance.get(@path, [
        [:description, "table[1]/tr[1]/td/text()"]
      ])[:description]
    end

    def level
      unless @level
        level_parts = Scraper.instance.get(@path, [
          [:token, "table[1]/tr[2]/td/a/text()", lambda {|x| x.split(':')[0]}],
          [:path, "table[1]/tr[2]/td/a/@href"]
        ])
        @level = Level.new(:token => level_parts[:token], :path => level_parts[:path])
      end
      @level
    end

    def notes
      @notes ||= Scraper.instance.get(@path, [
        [:notes, "table[1]/tr[3]/td/p/text()"]
      ])[:notes]
    end

    def count
      @count ||= Scraper.instance.get(@path, [
        [:count, "p[@class='count']/text()", lambda {|x| x.split(' ').first}]
      ])[:count]
    end

    def self.all
      @sources ||= Scraper.instance.get_all(Reconstruction, "/entry/", [
        [:path, 'td[2]/a/@href'],
        [:protoform, 'td[2]/a/text()'],
        [:description, 'td[3]/text()']
      ])
    end

    def self.count
      @count ||= Scraper.instance.get("/entry/", [
        [:count, "p[@class='count']/text()", lambda {|x| x.split(' ').first}]
      ])[:count]
    end

    def self.find(name)
      Scraper.instance.get_all(Reconstruction, "/search/?field=protoform&query=#{name}", [
        [:path, 'td[2]/a/@href'],
        [:protoform, 'td[2]/a/text()'],
        [:description, 'td[3]/text()']
      ])
    end
  end
end
