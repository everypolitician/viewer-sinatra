# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/page/term_table'

describe 'TermTable' do
  describe 'Austria' do
    subject do
      stub_popolo('3df153b', 'Austria/Nationalrat')
      Page::TermTable.new(
        term: index_at_known_sha.country('austria').legislature('nationalrat').term('25')
      )
    end

    it 'has a list of sources for Austria' do
      subject.data_sources.first.must_equal 'http://informationsfreiheit.at/'
    end

    it 'finds Austria as a country' do
      subject.country.name.must_equal 'Austria'
    end

    it 'finds nationalrat as a legislature' do
      subject.house.name.must_equal 'Nationalrat'
    end

    it 'has a list of terms for Austria' do
      subject.terms.first.start_date.to_s.must_equal '2013-09-29'
    end

    it 'shows the name in the title' do
      subject.title.must_include 'Austria'
    end

    it 'shows the house name in the title' do
      subject.title.must_include 'Nationalrat'
    end

    it 'shows the term in the title' do
      subject.title.must_include '25'
    end

    describe 'when calculating the group data' do
      it 'sends the right memberships' do
        group_data = subject.group_data
        group_data.count.must_equal 7

        group_data.first.group_id.must_equal 'spÖ'
        group_data.first.name.must_equal 'SPÖ'
        group_data.first.member_count.must_equal 51

        group_data.last.group_id.must_equal 'ohne_(none)'
        group_data.last.name.must_equal 'ohne (none)'
        group_data.last.member_count.must_equal 3
      end

      # TODO: it 'does not include group data if there is only a single group'
    end

    describe 'when constructing cards' do
      let(:af) { subject.people.find { |p| p.name == 'Angela Fichtinger' } }

      it 'has the correct id' do
        af.id.must_equal '2e8b774e-ae66-4137-a984-aac74917df87'
      end

      it 'has the correct name' do
        af.name.must_equal 'Angela Fichtinger'
      end

      it 'has the correct image' do
        af.image.must_equal 'http://www.parlament.gv.at/WWER/PAD_83146/4386378_180.jpg'
      end

      it 'has the correct proxy image' do
        af.proxy_image.must_equal 'https://mysociety.github.io/politician-image-proxy/' \
          'Austria/Nationalrat/2e8b774e-ae66-4137-a984-aac74917df87/140x140.jpeg'
      end

      it 'has a single membership' do
        af.memberships.count.must_equal 1
        af.memberships.first[:start_date].must_equal '2013-10-29'
        af.memberships.first[:end_date].must_equal nil
        af.memberships.first[:group].must_equal 'ÖVP'
        af.memberships.first[:area].must_equal 'Wahlkreis: 3B – Waldviertel'
      end

      it 'has two entries on bio card' do
        af.bio.count.must_equal 2
      end

      it 'has gender data' do
        af.bio.first.type.must_equal 'Gender'
        af.bio.first.value.must_equal 'female'
        af.bio.first.link.must_equal nil
      end

      it 'has birth data' do
        af.bio.last.type.must_equal 'Born'
        af.bio.last.value.must_equal '1956-12-29'
        af.bio.last.link.must_equal nil
      end

      it 'has a social card' do
        af.social.count.must_equal 1
        af.social.first.type.must_equal 'Facebook'
        af.social.first.value.must_equal 'angela.fichtinger'
        af.social.first.link.must_equal 'https://facebook.com/angela.fichtinger'
      end

      it 'has a contacts card' do
        af.contacts.count.must_equal 1
        af.contacts.first.type.must_equal 'Email'
        af.contacts.first.value.must_equal 'angela.fichtinger@parlament.gv.at'
        af.contacts.first.link.must_equal 'mailto:angela.fichtinger@parlament.gv.at'
      end

      it 'has two identifiers' do
        af.identifiers.count.must_equal 2
      end

      it 'has Wikidata' do
        af.identifiers.first.type.must_equal 'wikidata'
        af.identifiers.first.value.must_equal 'Q15783437'
        af.identifiers.first.link.must_equal 'https://www.wikidata.org/wiki/Q15783437'
      end

      it 'has a parliament identifier' do
        af.identifiers.last.type.must_equal 'parlaments_at'
        af.identifiers.last.value.must_equal '83146'
        af.identifiers.last.link.must_equal nil
      end
    end

    it 'knows percentage of people that have special data' do
      subject.percentages.social.must_equal 20
      subject.percentages.bio.must_equal 100
      subject.percentages.contacts.must_equal 93
      subject.percentages.identifiers.must_equal 100
    end
  end

  describe 'when the country has several terms' do
    subject do
      Page::TermTable.new(
        term: index_at_known_sha.country('uk').legislature('commons').term('55')
      )
    end

    it 'knows about the current term' do
      subject.current_term.slug.must_equal '55'
    end

    it 'knows about the previous term' do
      subject.prev_term.slug.must_equal '54'
    end

    it 'knows about the next term' do
      subject.next_term.slug.must_equal '56'
    end
  end
end
