require 'arxivsync'
require 'minitest/autorun'

TEST_ROOT = File.dirname(__FILE__)

class TestParser < Minitest::Test
  def test_parser
    archive = ArxivSync::XMLArchive.new(File.join(TEST_ROOT, 'fixtures'))
    tested_a_paper = false
    archive.read_metadata do |papers|
      assert_equal papers.count, 1000
      papers.each do |paper|
        if paper.id == "0704.4001"
          assert_equal paper.created, Date.parse("2007-04-30")
          assert_equal paper.updated, Date.parse("2008-01-28")
          assert_equal paper.title, "Warping and Supersymmetry Breaking"
          assert_equal paper.primary_category, "hep-th"
          assert_equal paper.crosslists, []
          assert_includes paper.abstract, "We finally point out various puzzles"
          assert_equal paper.authors.map(&:keyname), ["Douglas", "Shelton", "Torroba"]
          assert_equal paper.authors.map(&:forenames), ["Michael R.", "Jessie", "Gonzalo"]
          tested_a_paper = true
        end
      end
    end

    assert tested_a_paper
  end
end
