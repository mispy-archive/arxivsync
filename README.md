# arxivsync-0.0.2

Ruby OAI interface for harvesting the arXiv. Can be used to store and update an XML mirror of paper metadata, and parse the XML into Ruby objects to allow conversion into a friendlier format.

## Installation

```
  gem install arxivsync
```

## Usage

### Creating or updating an archive

```
  archive = ArxivSync::XMLArchive.new("/home/foo/savedir")
  archive.sync
```

Stores each XML response as an individual file, each containing up to 1000 records. Following an initial harvest, you can rerun this to add additional files containing all records since the last harvest.

Remember to leave at least a day between syncs-- the temporal granularity doesn't go any smaller than that!

### Reading from an archive

```
  archive = ArxivSync::XMLArchive.new("/home/foo/savedir")
  archive.read_metadata do |paper|
    # Do stuff with paper
  end
```

Parses the XML files using Nokogiri's SAX parser and yields Structs representing the metadata as it goes.

### Download and parse immediately

If you just want arxivsync to do the request-cycle and parsing bits but handle storage yourself:

```
  ArxivSync.get_metadata(oai_params) do |resp, papers|
    papers.each do |paper|
      # Do stuff with paper
    end 
  end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
