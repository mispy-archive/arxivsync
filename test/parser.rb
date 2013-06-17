require 'arxivsync'
require 'minitest/autorun'

TEST_ROOT = File.dirname(__FILE__)

class TestParser < Minitest::Test
  def test_parser
    archive = ArxivSync::XMLArchive.new(File.join(TEST_ROOT, 'fixtures'))
    tested = 0
    archive.read_metadata do |papers|
      assert_equal papers.count, 1000
      papers.each do |paper|
        if paper.id == "1302.0649"
          assert_equal paper.created, Date.parse("2013-02-04")
          assert_equal paper.updated, nil
          assert_equal paper.title, "Correlation effects in the electronic structure of the Ni-based superconducting KNi2S2"
          assert_equal paper.license, "http://creativecommons.org/licenses/by/3.0/"
          assert_equal paper.primary_category, "cond-mat.supr-con"
          assert_equal paper.crosslists, []
          assert_includes paper.abstract, "using Gutzwiller approximation method."
          assert_equal paper.authors.map(&:keyname), ["Lu", "Wang", "Xie", "Zhang"]
          assert_equal paper.authors.map(&:forenames), ["Feng", "Wei-Hua", "Xinjian", "Fu-Chun"]
          tested += 1
        end

        if paper.id == "1302.0758"
          assert_equal paper.authors[0].affiliation, "Baylor University, Waco, TX, USA"
          assert_equal paper.comments, "8 pages, 4 figures; presented by BFLW at ICHEP 2012"
          assert_equal paper.report_no, "BU-HEPP-12-05"
          tested += 1
        end
      end
    end

    assert_equal tested, 2
  end
end
