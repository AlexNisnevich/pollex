module Pollex
  # A level to which protoforms are reconstructed within Pollex.
  class Level < PollexObject
    extend PollexClass

    attr_accessor :token, :path
    attr_writer :subgroup, :count
    attr_inspector :token, :subgroup, :count, :path

    # Returns all Reconstructions at this Level
    # @return [Array<Reconstruction>] array of Reconstructions at this Level
    def reconstructions
      @reconstructions ||= Scraper.instance.get_all(Reconstruction, @path, [
        [:path, 'td[1]/a/@href'],
        [:protoform, 'td[1]/a/text()'],
        [:description, 'td[2]/text()']
      ])
    end

    # @return the full name of this Level
    def subgroup
      @subgroup ||= Scraper.instance.get(@path, [
        [:subgroup, 'h1/text()', lambda {|x| x.split(' - ')[1]}]
      ])[:subgroup]
    end

    # @return [Integer] number of Reconstructions at this Level
    def count
      @count ||= Scraper.instance.get(@path, [
        [:count, "p[@class='count']/text()", lambda {|x| x.split(' ').first}]
      ])[:count]
    end

    # Returns all Levels in Pollex.
    # @return [Array<Level>] array of Levels in Pollex
    def self.all
      @levels ||= Scraper.instance.get_all(Source, "/level/", [
        [:token, 'td[1]/a/text()'],
        [:subgroup, 'td[2]/a/text()'],
        [:path, 'td[2]/a/@href'],
        [:count, 'td[3]/a/text()'],
      ])
    end

    # Counts the number of Levels within Pollex
    # @return [Integer] number of Levels in Pollex
    def self.count
      self.all.count
    end
  end
end
