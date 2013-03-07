module Pollex
  # Singleton object for translating descriptions into English.
  class Translator
    include Singleton

    # Instantiates a cache of size 2500 for storing translations.
    def initialize()
      @cache = LRUCache.new(:max_size => 2500, :default => nil)
    end

    # Translates a phrase into English using the free MyMemory API, and caches
    # the result.
    # @note MyMemory currently has a limit of 2500 API requests per IP per day.
    #   However, it is unlikely that Pollex::Translator will ever exceed this limit.
    # @param phrase [String] Phrase to be translated
    # @param source_lang_code [String] Two-letter language code for the source language
    # @param target_lang_code [String] Two-letter language code for the target language
    #   (default: 'en')
    # @result [String] Translated phrase
    def translate(phrase, source_lang_code, target_lang_code = 'en')
      key = [phrase, source_lang_code, target_lang_code]
      if @cache[key]
        @cache[key]
      else
        url = "http://mymemory.translated.net/api/get?q=#{URI::encode(phrase)}&langpair=#{source_lang_code}%7C#{target_lang_code}"
        results_json = open(url).read
        result = JSON.parse(results_json)['responseData']['translatedText']
        @cache[key] = result
        result
      end
    end
  end
end
