require 'net/http'

module Jekyll

  class ESV < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @raw_text   = text
      tokens      = text.split /\,\s/
      @passage    = tokens[0]
      @parameters = {}

      tokens[1..-1].each do |arg|
        key, value = arg.split /:/
        value ||= "1"
        @parameters[key.strip] = value.strip
      end
      @options = ["include-short-copyright=0",
                   "include-passage-references=1",
                   "include-footnotes=0",
                   "include-chapter-numbers=0",
                   "include-headings=0",
                   "include-subheadings=0",
                   "include-audio-link=0",
                   "include-first-verse-numbers=0",
                   "include-passage-horizontal-lines=0",
                   "include-heading-horizontal-lines=0"].join("&")
      @base_url = "http://www.esvapi.org/v2/rest/passageQuery?key=IP"
    end

    def render(context)
      doPassageQuery @passage
    end

    def doPassageQuery(passage)
      passage = passage.strip!.gsub(/\s/, "+")
      passage = passage.gsub(/\:/, "%3A")
      passage = passage.gsub(/\,/, "%2C")

      # @base_url + "&passage=#{passage}&#{@options}"
      get_url @base_url + "&passage=#{passage}&#{@options}"
    end

    private

    def get_url(url)
      Net::HTTP.get(::URI.parse(url))
    end
  end
end

Liquid::Template.register_tag('esv', Jekyll::ESV)