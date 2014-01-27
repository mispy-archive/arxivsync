require 'oai'
require 'nokogiri'
require 'ox'
require 'colorize'
require 'latex/decode'
require 'arxivsync/version'
require 'arxivsync/parser'
require 'arxivsync/downloader'
require 'arxivsync/xmlarchive'

module ArxivSync
  class << self
    def parse_xml(xml)
      parser = XMLParser.new
      Ox.sax_parse(parser, StringIO.new(xml))
      parser.papers
    end

    def get_metadata(oai_params, &b)
      downloader = Downloader.new(oai_params)
      downloader.start do |resp|
        b.call(resp, parse_xml(resp.doc.to_s))
      end
    end
  end
end
