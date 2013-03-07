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
        [:source_code, nil, lambda {|x| @code}],
        [:source_path, nil, lambda {|x| @path}],
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

    # Returns grammatical information for this source, used for
    # intelligently parsing the descriptions of entries from this source
    # @note Information is currently entered for all sources on
    #   http://pollex.org.nz/source/ up to (and including)
    #   Bse
    # @return [Hash] grammatical information pertaining to the descriptions
    #   of this sources' entries
    # @see Entry#terms
    def grammar
      # first, assume reasonable defaults

      language = 'en' # default language: English
      dividers = /[,;]/ # default: split on comma and semicolon
      trim_expressions = '' # default: don't trim any expressions
      trim_after = nil # default: don't trim any trailing text

      # now bring in source-specific information

      if ['Cnt', 'Bxn'].include? @code
        # Spanish-language sources
        language = 'es'
      elsif ['Aca', 'Bgn', 'Btn', 'Hmn', 'Rch'].include? @code
        # French-language sources
        language = 'fr'
      end

      if ['Aca', 'Bxn'].include? @code
        # split by comma, semicolon, period
        dividers = /(,|;|\. )/
      elsif ['Atn', 'Bwh', 'Hmn'].include? @code
        # don't split at all
        dividers = '\n' # dividers = nil doesn't work
      elsif ['Bgn', 'Bst', 'Brn'].include? @code
        # split by period
        dividers = '.'
      elsif ['Bkr', 'Bgs'].include? @code
        # split by comma, period
        dividers = /(,|\. )/
      elsif ['Bge', 'Bck'].include? @code
        # split by semicolon
        dividers = ';'
      end

      if ['McP', 'Dsn'].include? @code
        # Trim all (parenthetical expressions)
        trim_expressions = /\(.*\)/
      elsif ['Cnt', 'Aca', 'Bse', 'Hmn'].include? @code
        # Trim parenthetical expressions that are <= 4 chars or contain numbers
        trim_expressions = /\((.{0,4}|.*[0-9].*)\)/
      elsif ['Stz', 'Bck'].include? @code
        # Trim parenthetical expressions that contain numbers
        trim_expressions = /\(.*[0-9].*\)/
      elsif ['Rsr'].include? @code
        # Trim all "expressions in quotes"
        trim_expressions = /".*"/
      end

      if ['Btl', 'Bck'].include? @code
        # Trim everything after a period
        trim_after = '.'
      end

      {
        :language => language,
        :dividers => dividers,
        :trim_expressions => trim_expressions,
        :trim_after => trim_after
      }
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

    # Counts the number of Sources within Pollex
    # @return [Integer] number of Sources in Pollex
    def self.count
      self.all.count
    end
  end
end
