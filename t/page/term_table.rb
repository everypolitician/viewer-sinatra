# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/page/term_table'

describe 'TermTable' do
  describe 'Austria' do
    before do
      stub_everypolitician_data_request('3df153b/data/Austria/Nationalrat/ep-popolo-v1.0.json')
    end

    subject do
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

    describe 'when getting the people for the current term' do
      it 'constructs the cards correctly' do
        af = subject.people.find { |p| p[:name] == 'Angela Fichtinger' }
        af.must_equal fichtinger_card
      end
    end

    it 'knows percentage of people that have special data' do
      expected = { social: 20, bio: 100, contacts: 93, identifiers: 100 }
      subject.percentages.must_equal expected
    end

    def fichtinger_card
      {
        id:          '2e8b774e-ae66-4137-a984-aac74917df87',
        name:        'Angela Fichtinger',
        image:       'http://www.parlament.gv.at/WWER/PAD_83146/4386378_180.jpg',
        proxy_image: 'https://mysociety.github.io/politician-image-proxy/Austria/Nationalrat/2e8b774e-ae66-4137-a984-aac74917df87/140x140.jpeg',
        memberships: [{ start_date: '2013-10-29', end_date: nil, group: 'ÖVP', area: 'Wahlkreis: 3B – Waldviertel' }],
        social:      [{ type: 'Facebook', value: 'angela.fichtinger', link: 'https://facebook.com/angela.fichtinger' }],
        bio:         [{ type: 'Gender', value: 'female' }, { type: 'Born', value: '1956-12-29' }],
        contacts:    [{ type: 'Email', value: 'angela.fichtinger@parlament.gv.at', link: 'mailto:angela.fichtinger@parlament.gv.at' }],
        identifiers: [{ type: 'wikidata', value: 'Q15783437', link: 'https://www.wikidata.org/wiki/Q15783437' }, { type: 'parlaments_at', value: '83146' }],
      }
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
