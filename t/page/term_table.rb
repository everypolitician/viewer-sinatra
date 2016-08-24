# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/page/term_table'

describe 'TermTable' do
  describe 'Austria' do
    subject do
      Page::TermTable.new(
        country_slug: 'austria',
        house_slug:   'nationalrat',
        term_id:      '25',
        index:        index_at_known_sha
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

    it 'has a url pointing to the popolo file' do
      subject.popolo_url.must_equal 'https://cdn.rawgit.com/everypolitician/everypolitician-data/3df153b/data/Austria/Nationalrat/ep-popolo-v1.0.json'
    end

    describe 'when calculating the group data' do
      it 'sends the right memberships' do
        subject.group_data.must_equal [
          { group_id: 'spÖ', name: 'SPÖ', member_count: 51 },
          { group_id: 'Övp', name: 'ÖVP', member_count: 51 },
          { group_id: 'fpÖ', name: 'FPÖ', member_count: 38 },
          { group_id: 'grüne', name: 'Grüne', member_count: 24 },
          { group_id: 'neos', name: 'NEOS', member_count: 9 },
          { group_id: 'team_stronach', name: 'Team Stronach', member_count: 6 },
          { group_id: 'ohne_(none)', name: 'ohne (none)', member_count: 3 },
        ]
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
      expected = { social: 20, bio: 100, contacts: 100, identifiers: 93 }
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

    def percentages
    end
  end

  describe 'when the country has several terms' do
    subject do
      Page::TermTable.new(
        country_slug: 'uk',
        house_slug:   'commons',
        term_id:      '55',
        index:        index_at_known_sha
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
