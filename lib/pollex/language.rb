module Pollex
  # A Polynesian language with entries in Pollex.
  class Language < PollexObject
    extend PollexClass

    attr_accessor :name, :path
    attr_writer :code, :count
    attr_inspector :name, :code, :count, :path

    # Returns all Entries belonging to this Language
    # @return [Array<Entry>] array of Entries belonging to this Language
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

    # @return [String] the Language's abbreviated code
    def code
      @code ||= @path.split('/')[2].upcase
    end

    # @return [Integer] number of Entries belonging to this Language
    def count
      @count ||= Scraper.instance.get(@path, [
        [:count, "p[@class='count']/text()", lambda {|x| x.split(' ').first}]
      ])[:count].to_i
    end

    # Returns all Languages in Pollex.
    # @return [Array<Language>] array of Languages in Pollex
    def self.all
      @languages ||= Scraper.instance.get_all(Language, "/language/", [
        [:name, 'td[2]/a/text()'],
        [:path, 'td[1]/a/@href'],
        [:code, 'td[1]/a/text()'],
        [:count, 'td[3]/text()']
      ])
    end

    # Counts the number of Languages within Pollex
    # @return [Integer] number of Languages in Pollex
    def self.count
      self.all.count
    end

    # Looks up all Languages matching a given name.
    # @param name [String] term to search for
    # @return [Array<Language>] array of Languages matching the search term
    def self.find(name)
      Scraper.instance.get_all(Language, "/search/?field=language&query=#{name}", [
        [:name, 'td[1]/a/text()'],
        [:path, 'td[1]/a/@href']
      ])
    end
  end
end
