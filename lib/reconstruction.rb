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
        [:source_name, 'td[4]/a/text()'],
        [:source_path, 'td[4]/a/@href'],
        [:flag, "td[3]/span[@class='flag']/text()"]
     ], 1)
    end

    def description
      @description ||= @attributes[:description]
    end

    def level
      level_code = @attributes[:level_code]
      level_path = @attributes[:level_path]
      @level ||= Level.new(:code => @level_code, :path => @level_path)
    end

    def notes
      @notes ||= @attributes[:notes]
    end

    def count
      @count ||= @attributes[:count]
    end

    def self.get_from_path(path)
      new(:path => path)
    end

    private

    def attributes
      @attributes ||= Scraper.get(@path, [
        [:description, "table[1]/tr[1]/td/text()"],
        [:level_code, "table[1]/tr[2]/td/a/text()", lambda {|x| x.split(':')[0]}],
        [:level_path, "table[1]/tr[2]/td/a/@href"],
        [:notes, "table[1]/tr[3]/td/p/text()"],
        [:count, "p[@class='count']/text()", lambda {|x| x.split(' ').first}]
      ])
    end
  end
end
