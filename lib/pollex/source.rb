module Pollex
  # A source of entries in Pollex.
  class Source < PollexObject
    extend PollexClass

    attr_accessor :code, :path
    attr_writer :name, :reference, :count
    attr_inspector :code, :name, :reference, :count, :path

    # Returns all Entries belonging to this Source
    # @return [Array<Entry>] array of Entries belonging to this Source
    def entries
      @entries ||= Scraper.instance.get_all(Entry, @path, [
        [:language_name, 'td[1]/a/text()'],
        [:language_path, 'td[1]/a/@href'],
        [:reflex, 'td[2]/text()'],
        [:description, 'td[3]/text()'],
        [:flag, "td[3]/span[@class='flag']/text()"]
     ])
    end

    # @return [String] full name of this Source
    def name
      @name ||= Scraper.instance.get(@path, [
        [:name, 'h1/text()', lambda {|x| x.match('Entries from (.*) in Pollex-Online')[1]}]
      ])[:name]
    end

    # @return [String] reference information for this Source
    def reference
      @reference ||= Scraper.instance.get(@path, [
        [:name, "p[@class='ref']/text()"]
      ])[:name]
    end

    # @return [Integer] number of Entries belonging to this Source
    def count
      @count ||= @entries.count
    end

    def grammar
      # defaults
      language = 'English'
      dividers = [',', ';']
      trim_expressions = 'none'

      # source-specific

      if ['Cnt'].include? @code
        language = 'Spanish'
      elsif ['Aca', 'Bgn', 'Btn'].include? @code
        language = 'French'
      end

      if ['Aca'].include? @code
        dividers = [',', ';', '.']
      elsif ['Atn', 'Bwh'].include? @code
        dividers = []
      elsif ['Bgn'].include? @code
        dividers = ['.']
      elsif ['Bkr'].include? @code
        dividers = [';', '.']
      elsif ['Bge'].include? @code
        dividers = [';']
      end

      if ['McP', 'Dsn'].include? @code
        # Trim all (parenthetical expressions)
        trim_parentheticals = 'parenthetical'
      elsif ['Cnt', 'Aca'].include? @code
        # Trim parenthetical expressions that are <= 3 chars or contain numbers
        trim_parentheticals = 'short_or_numbers'
      elsif ['Stz'].include? @code
        # Trim parenthetical expressions that contain numbers
        trim_parentheticals = 'numbers'
      elsif ['Rsr'].include? @code
        # Trim all "expressions in quotes"
        trim_parentheticals = 'quotes'
      elsif ['Btl'].include? @code
        # Trim everything after a period
        trim_parentheticals = 'after_period'
      end
    end

    # Returns all Sources in Pollex.
    # @return [Array<Source>] array of Sources in Pollex
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
