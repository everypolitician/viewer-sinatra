# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/page/house_wikidata'

def page_for(country, house)
  Page::HouseWikidata.new(
    house: index_at_known_sha.country(country).legislature(house)
  )
end

describe 'HouseWikidata' do
  let(:austria_page)  { page_for('austria',  'nationalrat') }
  let(:alderney_page) { page_for('alderney', 'states')      }
  let(:uganda_page)   { page_for('uganda',   'parliament')  }

  it 'should return a house' do
    austria_page.house.name.must_equal 'Nationalrat'
  end

  it 'should return a title' do
    austria_page.title.must_equal 'EveryPolitician: Austria — Nationalrat'
  end

  it 'should pass a list of people with wikidata' do
    austria_page.people_with_wikidata.map(&:name).must_include 'Cornelia Ecker'
  end

  it 'should pass an empty array when there are no people with wikidata' do
    alderney_page.people_with_wikidata.must_be_empty
  end

  it 'should pass an empty array when there are no people without wikidata' do
    austria_page.people_without_wikidata.must_be_empty
  end

  it 'should pass a list of people without wikidata' do
    uganda_page.people_without_wikidata.map(&:name).must_include 'Boaz Kafuda'
  end
end
