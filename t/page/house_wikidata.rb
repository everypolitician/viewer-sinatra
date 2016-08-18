require 'minitest/autorun'
require_relative '../../lib/page/house_wikidata'

describe 'HouseWikidata' do
  subject do
    Page::HouseWikidata.new('austria', 'nationalrat')
  end

  it 'should return a house' do
    subject.house[:name].must_equal 'Nationalrat'
  end

  it 'should return a page_title' do
    subject.page_title.must_equal 'EveryPolitician: Austria — Nationalrat'
  end

  it 'should return the country popolo' do
    popolo = subject.popolo
    keys = %i(posts persons organizations meta memberships events areas)
    (popolo.keys & keys).must_equal keys
  end
end
