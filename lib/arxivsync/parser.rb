module ArxivSync
  # Layout reference: http://www.xmlns.me/?op=visualize&id=643
  Version = Struct.new(
    :date, # Time.parse("Wed, 23 Jan 2008 21:06:41 GMT")
    :size # '121kb'
  )

  Paper = Struct.new(
    :id, # '0801.3673'
    :submitter, # 'N. C. Bacalis'
    :versions,
    :title, # "Variational Functionals for Excited States"
    :authors, # ['Naoum C. Bacalis']
    :categories, # ['quant-ph'] (primary category first, then crosslists)
    :abstract, # "Functionals that have local minima at the excited..."

    # These properties do not always appear
    :comments, # "4 pages"
    :msc_class, # '57M25'
    :report_no, # "LA-UR 07-7165"
    :journal_ref, # "JHEP 0805:087,2008."
    :doi, # "10.1088/1126-6708/2008/05/087"
    :proxy, # "ccsd hal-00214270"
    :license # "http://arxiv.org/licenses/nonexclusive-distrib/1.0/"
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
        @versions = []
      when :version
        @version = Version.new
      end
    end

    def clean(str)
      str.gsub(/\s+/, ' ').strip
    end

    def text(str)
      case @el
      # Necessary elements
      when :id
        @model.id = clean(str)
      when :submitter
        @model.submitter = clean(str)
      when :title
        @model.title = clean(str)
      when :authors
        @model.authors = clean(str).split(/,(?: and )*/)
      when :categories
        @model.categories = clean(str).split(/\s/)
      when :abstract
        @model.abstract = clean(str)

      # Optional elements
      when :comments
        @model.comments = clean(str)
      when :"msc-class"
        @model.msc_class = clean(str)
      when :"report-no"
        @model.report_no = clean(str)
      when :"journal-ref"
        @model.journal_ref = clean(str)
      when :doi
        @model.doi = clean(str)
      when :proxy
        @model.proxy = clean(str)
      when :license
        @model.license = clean(str)

      # Versions
      when :date
        @version.date = Time.parse(clean(str))
      when :size
        @version.size = clean(str)
      end
    end

    def end_element(name)
      case name
      when :version
        @versions.push(@version)
      when :metadata # End of a paper entry
        @model.versions = @versions

        @papers.push(@model)
      end
      @el = nil
    end
  end
end
