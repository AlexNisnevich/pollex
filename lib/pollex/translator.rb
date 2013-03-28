module Pollex
  # Singleton object for translating descriptions into English.
  class Translator
    include Singleton

    # Instantiates a cache of size 100 for storing translations.
    def initialize()
      @cache = LRUCache.new(:max_size => 2500, :default => nil)
    end

    # Translates a phrase into English using the free MyMemory API, and caches
    # the result.
    # @note MyMemory currently has a limit of 100 API requests per IP per day for
    #   unregistered users.
    # @param phrase [String] Phrase to be translated
    # @param source_lang_code [String] Two-letter language code for the source language
    # @param context [Array<String>] Adjoining phrases (optional)
    # @result [String] Translated phrase
    def translate(phrase, source_lang_code, context = nil)
      context ||= [phrase]
      if context.all? {|x| CLD.detect_language(x)[:code] == 'en'}
        # we are reasonably sure that this phrase is already in English - no need to translate
        phrase
      else
        # first, check the cache
        key = [phrase, source_lang_code]
        if @cache[key]
          @cache[key]
        else
          # make a request to MyMemory
          puts "Translating '#{phrase}' from (#{source_lang_code}) ..."
          url = "http://mymemory.translated.net/api/get?q=#{URI::encode(phrase)}&langpair=#{source_lang_code}%7Cen"
          results_json = open(url).read
          result = JSON.parse(results_json)['responseData']['translatedText']

          if result.include? 'MYMEMORY WARNING'
            # translation failed - return original phrase
            puts result
            phrase
          else
            # translation succeeded - store into cache and return translated phrase
            @cache[key] = result
            result
          end
        end
      end
    end
  end
end
