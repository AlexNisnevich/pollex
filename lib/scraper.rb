require 'nokogiri'
require 'open-uri'

module Pollex
  class Scraper
    def self.get(path, attr_paths)
      page = Nokogiri::HTML(open("http://pollex.org.nz#{path}"))
      rows = page.css('tr')
      rows[1...-1].map do |row|
        attrs = {}
        attr_paths.each do |name, xpath|
          attrs[name] = row.at_xpath(xpath).to_s.strip
        end
        attrs
      end
    end
  end
end
