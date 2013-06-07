require 'oai'
require 'nokogiri'
require 'arxivsync/version'
require 'arxivsync/parser'

module ArxivSync
  class XMLArchive
    def initialize(savedir, custom_params=nil)
      @savedir = savedir
      @oai = OAI::Client.new 'http://export.arxiv.org/oai2'
    end

    # Parse the timestamp from the path to a previously saved
    # arxiv xml block
    def parse_dt(path)
      DateTime.parse(path.split('/')[-1].split('_')[0])
    end

    def sync(initial_params={})
      initial_params[:metadataPrefix] ||= 'arXiv'

      # Get any existing xml files we may have, sorted by
      # their download timestamps
      existing = Dir.glob(File.join(@savedir, '*')).sort do |a,b|
        parse_dt(a) <=> parse_dt(b)
      end

      last_response = Nokogiri(File.open(existing[-1])).css('responseDate')
      
      resp = @last_params ? retry_request : make_request(initial_params)

      while true
        if !resp.resumption_token
          if resp.doc.to_s.include?("Retry after 20 seconds") # Rate limitation
            puts "Honoring 503 and sleeping for 20 seconds..."
            sleep 20
            resp = retry_request
          else # No resumption_token and no retry should mean we're finished
            save_response(resp)
            puts "Finished archiving!"
            break
          end
        else # We have a resumption_token, keep going!
          save_response(resp)
          resp = make_request(initial_params.merge(resumptionToken: resp.resumption_token))
        end
      end

      return self
    end

    def read_metadata(&b)
      doc = XMLDocument.new(&b)
      parser = Nokogiri::XML::SAX::Parser.new(doc)

      Dir.glob(File.join(@savedir, '*')).each do |path|
        parser.parse_file(path)
      end
    end

    def save_response(resp)
      # Saves a timestamped OAI XML response to disk, appending
      # the resumption token to the filename if available
      content = resp.doc.to_s
      filename = "#{DateTime.now.to_s}_#{resp.resumption_token || 'final'}"
      puts filename
      f = File.open("#{@savedir}/#{filename}", 'w')
      f.write(content)
      f.close
    end

    def retry_request
      make_request(@last_params)
    end

    def make_request(params)
      @last_params = params.clone
      begin
        @oai.list_records(params)
      rescue Faraday::Error::TimeoutError
        puts "Request timed out; retrying in 20 seconds"
        sleep 20
        retry_request
      end
    end
  end
end
