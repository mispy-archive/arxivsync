require 'ox'

module ArxivSync
  Author = Struct.new(
    :keyname, :forenames
  )

  Paper = Struct.new(
    :id, :created, :updated, :title, :abstract, :categories, :authors,
    :primary_category, :crosslists
  )

  class Parser < ::Ox::Sax
    attr_accessor :models

    def initialize(&block)
      @models = []
      @block = block
    end

    def start_element(name)
      @el = name
      case name
      when :author
        @author = Author.new
      end
    end

    def text(str)
      case @el
      when :id
        @model = Paper.new
        @model.id = str
        @authors = []
      when :created
        @model.created = Date.parse(str)
      when :updated
        @model.updated = Date.parse(str)
      when :title
        @model.title = str
      when :abstract
        @model.abstract = str
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

        if @block
          @block.call(@model)
        end

        @models.push(@model)
      end
      @el = nil
    end
  end
end
