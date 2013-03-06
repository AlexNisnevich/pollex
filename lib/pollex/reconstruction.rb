module Pollex
  # A reconstructed protoform in Pollex.
  class Reconstruction < PollexObject
    extend PollexClass

    attr_accessor :path, :protoform, :description, :semantic_field
    attr_inspector :protoform, :description, :path

    # Returns all Entries belonging to this Reconstruction
    # @return [Array<Entry>] array of Entries belonging to this Reconstruction
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

    # @return [String] the Reconstruction's description
    def description
      @description ||= Scraper.instance.get(@path, [
        [:description, "table[1]/tr[1]/td/text()"]
      ])[:description]
    end

    # @return [Level] the Level corresponding to this Reconstruction
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

    # @return [String] the Reconstruction's notes
    def notes
      @notes ||= Scraper.instance.get(@path, [
        [:notes, "table[1]/tr[3]/td/p/text()"]
      ])[:notes]
    end

    # @return [Integer] number of Entries belonging to this Reconstruction
    def count
      @count ||= Scraper.instance.get(@path, [
        [:count, "p[@class='count']/text()", lambda {|x| x.split(' ').first}]
      ])[:count]
    end

    # Returns all Reconstructions in Pollex.
    # @return [Array<Reconstruction>] array of Reconstructions in Pollex
    def self.all
      @sources ||= Scraper.instance.get_all(Reconstruction, "/entry/", [
        [:path, 'td[2]/a/@href'],
        [:protoform, 'td[2]/a/text()'],
        [:description, 'td[3]/text()']
      ])
    end

    # Counts the number of Reconstruction within Pollex
    # @return [Integer] number of Reconstruction in Pollex
    def self.count
      @count ||= Scraper.instance.get("/entry/", [
        [:count, "p[@class='count']/text()", lambda {|x| x.split(' ').first}]
      ])[:count]
    end

    # Looks up all Reconstructions matching a given name.
    # @param name [String] term to search for
    # @return [Array<Reconstruction>] array of Reconstructions matching the search term
    def self.find(name)
      Scraper.instance.get_all(Reconstruction, "/search/?field=protoform&query=#{name}", [
        [:path, 'td[2]/a/@href'],
        [:protoform, 'td[2]/a/text()'],
        [:description, 'td[3]/text()']
      ])
    end
  end
end
