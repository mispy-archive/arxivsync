# arxivsync-0.0.1

Ruby OAI interface for harvesting the arXiv. Can be used to store and update an XML mirror of paper metadata, and parse the XML into Ruby objects to allow conversion into a friendlier format.

## Installation

```
  gem install arxivsync
```

## Usage

### Downloading

```
  archive = ArxivSync::XMLArchive.new("/home/foo/savedir")
  archive.sync
```

### Reading an existing archive

```
  archive = ArxivSync::XMLArchive.new("/home/foo/savedir")
  archive.read_metadata do |paper|
    p paper
  end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
