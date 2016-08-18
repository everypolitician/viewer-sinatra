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
    popolo[:events].first[:name].must_equal 'Austrian Constitutional Assembly election, 1919'
    popolo[:events].first[:classification].must_equal 'general election'
  end
end
