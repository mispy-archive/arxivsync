module ArxivSync
  Author = Struct.new(
    :keyname, :forenames
  )

  Paper = Struct.new(
    :id, :created, :updated, :title, :abstract, :authors,
    :primary_category, :crosslists
  )

  class XMLParser < ::Ox::Sax
    attr_accessor :papers

    def start_element(name, attributes=[])
      @el = name
      case name
      when :ListRecords
        @papers = []
      when :metadata
        @model = Paper.new
        @authors = []
      when :author
        @author = Author.new
      end
    end

    def clean(str)
      str.gsub(/\s+/, ' ').strip
    end

    def text(str)
      case @el
      when :id
        @model.id = str
      when :created
        @model.created = Date.parse(str)
      when :updated
        @model.updated = Date.parse(str)
      when :title
        @model.title = clean(str)
      when :abstract
        @model.abstract = clean(str)
      when :categories
        @model.primary_category = str.split[0]
        @model.crosslists = str.split.drop(1)
      when :keyname
        @author.keyname = str
      when :forenames
        @author.forenames = str
      end
    end

    def end_element(name)
      case name
      when :author
        @authors.push(@author)
      when :metadata # End of a paper entry
        #@paper.updated_date ||= @paper.pubdate # If no separate updated date
        #@paper.feed_id = Feed.get_or_create(@primary_category).id
        @model.authors = @authors

        @papers.push(@model)
      end
      @el = nil
    end
  end
end
