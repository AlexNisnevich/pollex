module Pollex
end

require 'nokogiri'
require 'lrucache'
require 'json'

require 'singleton'
require 'open-uri'
require 'pp'

[
  'version',
  'pollex_class',
  'scraper',
  'translator',
  'entry',
  'language',
  'reconstruction',
  'semantic_field',
  'source',
  'level'
].each do |file|
  require File.dirname(__FILE__) + "/pollex/#{file}.rb"
end
