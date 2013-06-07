require 'oai'
require 'nokogiri'
require 'arxivsync/version'
require 'arxivsync/parser'

module ArxivSync
  class XMLArchive
    def initialize(savedir, custom_params=nil)
      @savedir = savedir
      begin Dir.mkdir(@savedir) # Ensure this directory exists
      rescue Errno::EEXIST
      end
      @oai = OAI::Client.new('http://export.arxiv.org/oai2', :parser => 'libxml')
    end

    # Parse the timestamp from the path to a previously saved
    # arxiv xml block
    def parse_dt(path)
      DateTime.parse(path.split('/')[-1].split('_')[0])
    end

    # Download from the arXiv!
    # This can be called in three potential states:
    # - The savedir has yet to be populated with any xml, meaning we need to
    #   start a full mirror of the entire database.
    #
    # - The most recent xml file contains a resumptionToken, meaning the last
    #   harvest attempt was aborted prematurely and we need to resume.
    #
    # - The most recent xml file does not have a resumptionToken, in which case
    #   we begin a new harvest for everything since the responseDate of the last.
    def sync(oai_params={})
      oai_params[:metadataPrefix] ||= 'arXiv'

      # Find any existing xml files we may have, sorted by
      # responseDate in the filename
      existing = Dir.glob(File.join(@savedir, '*')).sort do |a,b|
        parse_dt(a) <=> parse_dt(b)
      end

      if existing.empty?
        puts "Commencing full arXiv download. This will take quite a while.\n" +
             "Download can be safely aborted at any point and will resume from\n" +
             "last successful response."
      else
        # Parse the most recent one
        last_response = Nokogiri::XML(File.open(existing[-1]))
        last_token = last_response.css('resumptionToken').text


        if last_token.empty? # Previous sync completed successfully
          responseDate = Date.parse(last_response.css('responseDate').text)
          if responseDate == Date.today
            puts "Last responseDate was today. arXiv lacks date granularity beyond the day level; please wait before continuing harvest."
            return false
          end
          puts "Downloading from last responseDate: #{responseDate}"
          oai_params[:from] ||= responseDate
        else # Previous sync aborted prematurely, resume
          puts "Resuming download using previous resumptionToken: #{last_token}"
          oai_params[:resumptionToken] ||= last_token
        end
      end
      
      # Make the initial request
      resp = @last_params ? retry_request : make_request(oai_params)

      # Continue to make requests until the server stops sending
      # resumption tokens
      while true
        if !resp.resumption_token || resp.resumption_token.empty?
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

    # Parses the archive using Nokogiri's SAX parser
    # Yields Paper objects as they are created
    def read_metadata(&b)
      doc = XMLDocument.new(&b)
      parser = Nokogiri::XML::SAX::Parser.new(doc)

      Dir.glob(File.join(@savedir, '*')).each do |path|
        parser.parse_file(path)
      end
    end

    # Saves a timestamped OAI XML response to disk, appending
    # the resumption token to the filename if available
    def save_response(resp)
      content = resp.doc.to_s

      # Parse the response and extract some metadata
      doc = Nokogiri::XML(content)

      # responseDate for stamping files and potentially
      # initiating the next harvest
      responseDate = doc.css('responseDate').text

      # Total number of records in this harvest
      completeListSize = doc.css('resumptionToken').attr('completeListSize').value.to_i
      # How far we are in
      cursor = doc.css('resumptionToken').attr('cursor').value.to_i
      # How many records we gained in this response
      numRecords = doc.css('record').count.to_i

      # If we have a resumption_token, stick that on the filename.
      if resp.resumption_token && !resp.resumption_token.empty?
        suffix = resp.resumption_token
      else
        suffix = 'final'
      end

      # Write out the file and communicate progress
      filename = "#{responseDate}_#{suffix}"
      f = File.open("#{@savedir}/#{filename}", 'w')
      f.write(content)
      f.close
      puts "Saved #{cursor+numRecords}/#{completeListSize} records to #{filename}"
    end

    def retry_request
      make_request(@last_params)
    end

    def make_request(params)
      # OAI doesn't like being passed anything else + resumptionToken
      if params[:resumptionToken]
        params = { resumptionToken: params[:resumptionToken] }
      end

      puts "Making OAI request with params: #{params.inspect}"

      @last_params = params.clone # list_records will nuke our params

      begin
        return @oai.list_records(params)
      rescue Faraday::Error::TimeoutError
        puts "Request timed out; retrying in 20 seconds"
        sleep 20
        return retry_request
      end
    end
  end
end
