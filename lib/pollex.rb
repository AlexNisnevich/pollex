module Pollex
end

require 'nokogiri'
require 'lrucache'

[
  'version',
  'pollex_class',
  'scraper',
  'entry',
  'language',
  'reconstruction',
  'semantic_field',
  'source',
  'level'
].each do |file|
  require File.dirname(__FILE__) + "/pollex/#{file}.rb"
end
