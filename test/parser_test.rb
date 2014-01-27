require_relative 'test_helper'
require 'minitest/autorun'

require 'arxivsync'

TEST_ROOT = File.dirname(__FILE__)

class TestParser < Minitest::Test
  def test_parser
    archive = ArxivSync::XMLArchive.new(File.join(TEST_ROOT, 'fixtures'))
    tested = 0
    archive.read_metadata do |papers|
      assert_equal papers.count, 1000
      papers.each do |paper|
        if paper.id == '0801.3673'
          assert_equal paper.submitter, "N. C. Bacalis"

          assert_equal paper.versions.length, 1
          assert_equal paper.versions[0].date, Time.parse("Wed, 23 Jan 2008 21:06:41 GMT")
          assert_equal paper.versions[0].size, "121kb"

          assert_equal paper.title, "Variational Functionals for Excited States"

          assert_equal paper.authors, ["Naoum C. Bacalis"]
          assert_equal paper.categories, ["quant-ph"]

          assert_equal paper.comments, "4 pages"
          assert_equal paper.abstract, "Functionals that have local minima at the excited states of a non degenerate Hamiltonian are presented. Then, improved mutually orthogonal approximants of the ground and the first excited state are reported."
          tested += 1
        end

        if paper.id == '0801.3720'
          assert_equal paper.submitter, "Xin-Zhong Yan"

          assert_equal paper.versions.length, 2
          assert_equal paper.versions[0].date, Time.parse("Thu, 24 Jan 2008 09:31:59 GMT")
          assert_equal paper.versions[0].size, "56kb"
          assert_equal paper.versions[1].date, Time.parse("Wed, 14 May 2008 02:16:45 GMT")
          assert_equal paper.versions[1].size, "58kb"
          
          assert_equal paper.title, "Weak Localization of Dirac Fermions in Graphene"
          assert_equal paper.authors, ["Xin-Zhong Yan", "C. S. Ting"]
          assert_equal paper.categories, ["cond-mat.str-el"]
          assert_equal paper.comments, "4 pages, 4 figures"
          assert_equal paper.journal_ref, "PRL 101, 126801 (2008)"
          assert_equal paper.doi, "10.1103/PhysRevLett.101.126801"
          assert_equal paper.abstract, "In the presence of the charged impurities, we study the weak localization (WL) effect by evaluating the quantum interference correction (QIC) to the conductivity of Dirac fermions in graphene. With the inelastic scattering rate due to electron-electron interactions obtained from our previous work, we investigate the dependence of QIC on the carrier concentration, the temperature, the magnetic field and the size of the sample. It is found that WL is present in large size samples at finite carrier doping. Its strength becomes weakened/quenched when the sample size is less than a few microns at low temperatures as studied in the experiments. In the region close to zero doping, the system may become delocalized. The minimum conductivity at low temperature for experimental sample sizes is found to be close to the data."
          tested += 1
        end

        if paper.id == "0801.3713"
          # Ensure latex-decode works properly
          assert_equal "Jean-Claude Léon (LGS)", paper.authors[2]
        end
      end
    end

    assert_equal tested, 2
  end
end
