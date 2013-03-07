require File.expand_path('../lib/pollex/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'pollex'
  s.version     = Pollex::VERSION

  s.summary     = "Ruby wrapper for scraping pollex (the Polynesian Lexicon Project)"
  s.description = s.summary
  s.authors     = ["Alex Nisnevich"]
  s.email       = 'alex.nisnevich@gmail.com'
  s.homepage    = 'http://github.com/AlexNisnevich/pollex'

  s.files       = `git ls-files`.split("\n")

  s.add_dependency 'nokogiri'
  s.add_dependency 'lrucache'
  s.add_dependency 'cld'
  s.add_dependency 'json'
end
