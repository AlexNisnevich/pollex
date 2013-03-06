Gem::Specification.new do |s|
  s.name        = 'pollex'
  s.version     = '0.0.2'
  s.date        = '2013-03-04'
  s.summary     = "Ruby wrapper for scraping pollex (the Polynesian Lexicon Project)"
  s.description = ""
  s.authors     = ["Alex Nisnevich"]
  s.email       = 'alex.nisnevich@gmail.com'
  s.homepage    = 'http://github.com/AlexNisnevich/pollex'

  s.files       = `git ls-files`.split("\n")

  s.add_dependency 'nokogiri'
  s.add_dependency 'lrucache'
end
