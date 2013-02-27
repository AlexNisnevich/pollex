require 'nokogiri'
require 'open-uri'

module Pollex
  class Scraper
    # gets all elements from table by xpath, with optional post-processing
    def self.get_all(klass, path, attr_infos, table_num = 0)
      puts "Connecting to http://pollex.org.nz#{path} ..."
      page = Nokogiri::HTML(open("http://pollex.org.nz#{path}"))

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

    # gets arbitrary data from page by xpath, with optional post-processing
    def self.get(path, attr_infos)
      puts "Connecting to http://pollex.org.nz#{path} ..."
      page = Nokogiri::HTML(open("http://pollex.org.nz#{path}"))
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
  end

  # array with a pointer to the next page of results
  class PaginatedArray < Array
    attr_accessor :next_page, :query

    def inspect
      str = super.inspect
      if @next_page
        str += "\nThere are more items available at #{@next_page}. Use _.more to get them."
      end
      str
    end

    def more
      if @next_page
        Scraper.get_all(query[:klass], @next_page, query[:attr_infos], query[:table_num])
      else
        nil
      end
    end
  end
end
