require 'oai'
require 'nokogiri'
require 'arxivsync/version'
require 'arxivsync/parser'
require 'arxivsync/xmlarchive'

module ArxivSync
  class << self
    def parse_xml(xml, &b)
      doc = XMLDocument.new(&b)
      parser = Nokogiri::XML::SAX::Parser.new(doc)
      parser.parse(xml)
    end

    def get_metadata(oai_params, &b)
      downloader = Downloader.new(oai_params)
      downloader.start do |resp|
        papers = []
        parse_xml(resp.doc.to_s) do |paper|
          papers.push(paper)
        end

        b.call(resp, papers)
      end
    end
  end
end
