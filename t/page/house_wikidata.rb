# frozen_string_literal: true
require 'minitest/autorun'
require_relative '../../lib/page/house_wikidata'

describe 'HouseWikidata' do
  subject do
    Page::HouseWikidata.new(country: 'austria', house: 'nationalrat', index: index_at_known_sha)
  end

  it 'should return a house' do
    subject.house.name.must_equal 'Nationalrat'
  end

  it 'should return a page_title' do
    subject.page_title.must_equal 'EveryPolitician: Austria — Nationalrat'
  end

  it 'should have popolo with wikidata' do
    stub_request(:get, 'https://cdn.rawgit.com/everypolitician/everypolitician-data/3df153b/data/Austria/Nationalrat/ep-popolo-v1.0.json')
      .to_return(body: File.read('t/fixtures/3df153b-Austria-Nationalrat-ep-popolo-v1.0.json'))
    andrea = '0eedf2c9-01ea-44f4-bc6e-e5e4bf6d2add'
    subject.popolo.persons.find_by(id: andrea).wikidata.must_equal 'Q493950'
  end
end
