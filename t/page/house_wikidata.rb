# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/page/house_wikidata'

describe 'HouseWikidata' do
  subject do
    Page::HouseWikidata.new(
      country: 'austria',
      house:   'nationalrat',
      index:   index_at_known_sha
    )
  end

  it 'should return a house' do
    subject.house.name.must_equal 'Nationalrat'
  end

  it 'should return a title' do
    subject.title.must_equal 'EveryPolitician: Austria — Nationalrat'
  end

  it 'should pass a list of people with wikidata' do
    subject.people_with_wikidata.map(&:name).must_include 'Cornelia Ecker'
  end

  it 'should pass an empty array when there are no people with wikidata' do
    test_page = Page::HouseWikidata.new(
      country: 'alderney',
      house:   'states',
      index:   index_at_known_sha
    )
    test_page.people_with_wikidata.must_be_empty
  end

  it 'should pass an empty array when there are no people without wikidata' do
    subject.people_without_wikidata.must_be_empty
  end

  it 'should pass a list of people without wikidata' do
    test_page = Page::HouseWikidata.new(
      country: 'uganda',
      house:   'parliament',
      index:   index_at_known_sha
    )
    test_page.people_without_wikidata.map(&:name).must_include 'Boaz Kafuda'
  end
end
