module Pollex
  class Level < PollexObject
    extend PollexClass

    attr_accessor :token, :path
    attr_writer :subgroup, :count
    attr_inspector :token, :subgroup, :count, :path

    def reconstructions
      @reconstructions ||= Scraper.instance.get_all(Reconstruction, @path, [
        [:path, 'td[1]/a/@href'],
        [:protoform, 'td[1]/a/text()'],
        [:description, 'td[2]/text()']
      ])
    end

    def subgroup
      @subgroup ||= Scraper.instance.get(@path, [
        [:subgroup, 'h1/text()', lambda {|x| x.split(' - ')[1]}]
      ])[:subgroup]
    end

    def count
      @count ||= Scraper.instance.get(@path, [
        [:count, "p[@class='count']/text()", lambda {|x| x.split(' ').first}]
      ])[:count]
    end

    def self.all
      @levels ||= Scraper.instance.get_all(Source, "/level/", [
        [:token, 'td[1]/a/text()'],
        [:subgroup, 'td[2]/a/text()'],
        [:path, 'td[2]/a/@href'],
        [:count, 'td[3]/a/text()'],
      ])
    end

    def self.count
      self.all.count
    end
  end
end
