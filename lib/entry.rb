module Pollex
  class Entry
    include InstantiateWithAttrs

    attr_accessor :reflex, :description, :reconstruction_name, :reconstruction_path
    attr_accessor :language_name, :language_path, :source_code, :source_path, :flag

    def path
      @reconstruction_path
    end

    def language
      @language ||= Language.new(:name => @language_name, :path => @language_path)
    end

    def source
      if @source_path
        @source ||= Source.new(:code => @source_code, :path => @source_path)
      else
        nil
      end
    end

    def reconstruction
      if @reconstruction_path
        @reconstruction ||= Reconstruction.new(:protoform => @reconstruction_name, :path => @reconstruction_path)
      else
        nil
      end
    end

    def self.find(name)
      Scraper.get_all(Entry, "/search/?field=entry&query=#{name}", [
        [:reflex, 'td[3]/text()'],
        [:description, 'td[4]/text()'],
        [:language_path, 'td[1]/a/@href'],
        [:language_name, 'td[1]/a/text()'],
        [:reconstruction_path, 'td[2]/a/@href'],
        [:reconstruction_name, 'td[2]/a/text()', lambda {|x| x.split('.')[1..-1].join('.')}],
        [:flag, "td[3]/span[@class='flag']/text()"]
      ])
    end
  end
end
