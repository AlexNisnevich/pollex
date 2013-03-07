module Pollex
  # Singleton object for scraping Pollex, caching the results, and extracting data.
  class Scraper
    include Singleton

    attr_accessor :verbose

    # Instantiates a cache of size 100 for storing scraped pages.
    def initialize()
      @cache = LRUCache.new(:max_size => 100, :default => nil)
      @verbose = false
    end

    # Opens the given Pollex page, either by retrieving it from the cache
    # or by making a request with Nokogiri and then storing it in the cache.
    # @param path [String] relative path from <tt>http://pollex.org.nz</tt>
    # @return [Nokogiri::HTML::Document] the requested page, parsed with Nokogiri
    def open_with_cache(path)
      if @cache[path]
        if @verbose
          puts "Opening cached contents of http://pollex.org.nz#{path} ..."
        end
        @cache[path]
      else
        if @verbose
          puts "Connecting to http://pollex.org.nz#{path} ..."
        end
        page = Nokogiri::HTML(open("http://pollex.org.nz#{path}"))
        @cache[path] = page
        page
      end
    end

    # Gets arbitrary data from a page, with optional post-processing.
    # @param path [String] relative path from <tt>http://pollex.org.nz</tt>
    # @param attr_infos [Array<Array<Symbol, String, (Proc, nil)>>] an array that,
    #   for each element to be scraped, contains an array of:
    #   * a key for the element
    #   * the XPath to the element, from the <tt>div#content</tt> tag of the page
    #   * (optionally) a Proc to be performed on the element's contents
    # @return [Array<Symbol, String>] array of key-value pairs
    # @example Return information about the level of a given reconstruction
    #   Scraper.instance.get(@reconstruction_path, [
    #     [:level_token, "table[1]/tr[2]/td/a/text()", lambda {|x| x.split(':')[0]}],
    #     [:level_path, "table[1]/tr[2]/td/a/@href"]
    #   ])
    def get(path, attr_infos)
      page = open_with_cache(path)
      contents = page.css('#content')

      attrs = {}
      attr_infos.each do |name, xpath, post_processor|
        attrs[name] = ''
        if xpath
          attrs[name] = contents.at_xpath(xpath).to_s.strip
        end
        if post_processor
          attrs[name] = post_processor.call(attrs[name])
        end
      end
      attrs
    end

    # Gets all elements from a table within a page, with optional post-processing.
    # The results are returned as either an array of key-value pairs or as an
    # array of objects, if a klass is specifed. If more than one page of results is
    # found, the first page of results is returned as a PaginatedArray.
    # @param klass [Class] (optional) class of objects to be instantiated
    # @param path [String] relative path from <tt>http://pollex.org.nz</tt>
    # @param attr_infos [Array<Array<Symbol, String, (Proc, nil)>>] an array that,
    #   for each element to be scraped, contains an array of:
    #   * a key for the element
    #   * the XPath to the element, from a given table
    #   * (optionally) a Proc to be performed on the element's contents
    # @param table_num [Integer] the number of the table on the page to process
    #   (default: 0 - that is, the first table on the page)
    # @return [Array<klass>] if one page of results was found
    # @return [PaginatedArray<klass>] if multiple pages of results were found
    # @return [Array<Array<Symbol, String>>] if no klass is specified
    # @example Return an array of all SemanticFields in Pollex
    #   Scraper.instance.get_all(SemanticField, "/category/", [
    #     [:id, 'td[1]/a/text()'],
    #     [:path, 'td[1]/a/@href'],
    #     [:name, 'td[2]/a/text()'],
    #     [:count, 'td[3]/text()']
    #   ])
    def get_all(klass, path, attr_infos, table_num = 0)
      page = open_with_cache(path)

      rows = page.css('table')[table_num].css('tr')
      objs = rows[1..-1].map do |row|
        attrs = {}
        attr_infos.each do |name, xpath, post_processor|
          attrs[name] = ''
          if xpath
            attrs[name] = row.at_xpath(xpath).to_s.strip
          end
          if post_processor
            attrs[name] = post_processor.call(attrs[name])
          end
        end
        attrs
      end

      # check if there is a "next" page
      last_link = page.css('.pagination a').last()
      if last_link and last_link.text()[0..3] == 'Next'
        last_link_path = last_link.attributes()['href']
        new_path = path.split('?')[0] + last_link_path

        results = PaginatedArray.new()
        results.query = {:klass => klass, :attr_infos => attr_infos, :table_num => table_num}
        results.next_page = new_path
        results.concat(objs.to_a) # merge rather than create new array
      else
        results = objs
      end

      if klass
        results.map! {|x| klass.new(x) }
      end

      results
    end
  end

  # Array with an optional pointer to the next page of results
  class PaginatedArray < Array
    attr_accessor :next_page, :query

    def inspect
      str = super.inspect
      if @next_page
        str += "\nThere are more items available at #{@next_page}. Use _.more to get them."
      end
      str
    end

    # Returns the next page of results, if one exists
    # @return PaginatedArray<@query[:klass]>
    # @see Scraper#get_all
    def more
      if @next_page
        Scraper.instance.get_all(query[:klass], @next_page, query[:attr_infos], query[:table_num])
      else
        nil
      end
    end
  end
end
