# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/page/term_table'

describe 'TermTable' do
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
    subject.house[:name].must_equal 'Nationalrat'
  end

  it 'has a list of terms for Austria' do
    subject.terms.first[:start_date].must_equal '2013-09-29'
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

    it 'knows which term comes after 55 for the UK - House of Commons' do
      subject.next_term[:slug].must_equal '56'
    end

    it 'knows which term comes before 55 for the UK - House of Commons' do
      subject.prev_term[:slug].must_equal '54'
    end

    it 'knows about the current term' do
      subject.current_term[:slug].must_equal '55'
    end
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

  it 'has a url pointing to the csv file' do
    subject.csv_url.must_equal 'https://cdn.rawgit.com/everypolitician/everypolitician-data/3df153b/data/Austria/Nationalrat/term-25.csv'
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

    # it 'does not include group data if there is only a single group' do
    #   subject.group_data
    # end
  end

  describe 'when getting the people for the current term' do
    it 'sends the right people' do
      subject.people.first.must_equal person
    end
  end

  it 'knows percentage of people that have special data' do
    subject.percentages.must_equal percentages
  end

  def person
    {
      id:          '0eedf2c9-01ea-44f4-bc6e-e5e4bf6d2add',
      name:        'Andrea Gessl-Ranftl',
      image:       'http://www.parlament.gv.at/WWER/PAD_51527/4385218_180.jpg',
      proxy_image: 'https://mysociety.github.io/politician-image-proxy/Austria/Nationalrat/0eedf2c9-01ea-44f4-bc6e-e5e4bf6d2add/140x140.jpeg',
      memberships: [{ start_date: nil, end_date: nil, group: 'SPÖ', area: 'Wahlkreis: 6D – Obersteiermark' }],
      social:      [],
      bio:         [{ type: 'Gender', value: 'female' }, { type: 'Born', value: '1964-11-16' }],
      contacts:    [{ type: 'Email', value: 'andrea.gessl-ranftl@aon.at', link: 'mailto:andrea.gessl-ranftl@aon.at' }],
      identifiers: [{ type: 'wikidata', value: 'Q493950', link: 'https://www.wikidata.org/wiki/Q493950' }, { type: 'parlaments_at', value: '51527' }],
    }
  end

  def percentages
    {
      social:      20,
      bio:         100,
      contacts:    100,
      identifiers: 93,
    }
  end
end
