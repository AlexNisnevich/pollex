module Pollex
  # A Pollex entry, corresponding to a reflex for a reconstruction, with a language and a source.
  class Entry < PollexObject
    extend PollexClass

    attr_accessor :reflex, :description, :language_name, :source_code, :reconstruction_name, :flag
    attr_writer :reconstruction_name, :reconstruction_path
    attr_writer :language_name, :language_path
    attr_writer :source_code, :source_path
    attr_inspector :reflex, :description, :language_name, :source_code, :reconstruction_name, :flag

    # @return [(String, nil)] the path to this entry, if given
    # @note In some Pollex listings, entries' paths are not listed.
    def path
      @reconstruction_path
    end

    def terms
      string = @description
      grammar = description_grammar

      # trim last part of description, if necessary
      if grammar[:trim_after]
        string = string.split(grammar[:trim_after])[0]
      end

      # split into terms, remove any unnecessary expressions
      terms = string.split(grammar[:dividers])
                    .map {|t| t.sub(grammar[:trim_expressions], '')
                               .strip
                               .capitalize }
                    .select {|t| t.match(/\w/) }

      # attempt to translate to English if necessary
      if grammar[:language] != 'en'
        terms.map! {|t| Translator.instance.translate(t, grammar[:language]) }
      end

      terms
    end

    # @return [Language] the Language corresponding to this entry
    def language
      if @language_path
        @language ||= Language.new(:name => @language_name, :path => @language_path)
      else
        nil
      end
    end

    # @return [(Source, nil)] the Source corresponding to this entry, if given
    # @note In some Pollex listings, entries' sources are not listed.
    def source
      if @source_path
        @source ||= Source.new(:code => @source_code, :path => @source_path)
      else
        nil
      end
    end

    # @return [(Reconstruction, nil)] the Reconstruction corresponding to this entry, if given
    # @note In some Pollex listings, entries' reconstructions are not listed.
    def reconstruction
      if @reconstruction_path
        @reconstruction ||= Reconstruction.new(:protoform => @reconstruction_name, :path => @reconstruction_path)
      else
        nil
      end
    end

    # Looks up all Entries matching a given name.
    # @param name [String] term to search for
    # @return [Array<Entry>] array of Entries matching the search term
    def self.find(name)
      Scraper.instance.get_all(Entry, "/search/?field=entry&query=#{name}", [
        [:reflex, 'td[3]/text()'],
        [:description, 'td[4]/text()'],
        [:language_path, 'td[1]/a/@href'],
        [:language_name, 'td[1]/a/text()'],
        [:reconstruction_path, 'td[2]/a/@href'],
        [:reconstruction_name, 'td[2]/a/text()', lambda {|x| x.split('.')[1..-1].join('.')}],
        [:flag, "td[3]/span[@class='flag']/text()"]
      ])
    end

    private

    def description_grammar
      if source
        source.grammar
      else
        Source.new.grammar
      end
    end
  end
end
