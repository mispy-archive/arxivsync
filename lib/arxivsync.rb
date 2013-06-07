require 'oai'
require 'arxivsync/version'
require 'arxivsync/parser'

module ArxivSync
  class XMLArchive
    def initialize(savedir, custom_params=nil)
      @savedir = savedir
      @initial_params = custom_params || { metadataPrefix: 'arXiv' }
      @oai = OAI::Client.new 'http://export.arxiv.org/oai2'
    end

    def sync
      resp = @last_params ? retry_request : make_request(@initial_params)

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
          resp = make_request(resumptionToken: resp.resumption_token)
        end
      end

      return self
    end

    def read_metadata(&b)
      Dir.glob(File.join(@savedir, '*')).each do |path|
        parser = Parser.new(&b)
        Ox.sax_parse(parser, File.open(path))
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
