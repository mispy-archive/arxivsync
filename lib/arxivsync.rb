require 'oai'
require 'nokogiri'
require 'arxivsync/version'
require 'arxivsync/parser'
require 'arxivsync/downloader'
require 'arxivsync/xmlarchive'

module ArxivSync
  class << self
    def parse_xml(xml)
      parser = XMLParser.new
      parser.parse(xml)
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
