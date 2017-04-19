# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/subviews/person_social'
require 'everypolitician'

describe 'Social Subview' do
  it 'should give a list of twitter and facebook details for a given member' do
    persons = index_at_known_sha.country('uk').legislature('commons').popolo.persons
    harriett = persons.select { |p| p.name == 'Harriett Baldwin' }.first
    card = PersonSocial.new(person: harriett)
    harriett_twitter = { name: 'Twitter', value: 'HBaldwinMP', url: 'http://twitter.com/HBaldwinMP' }
    harriett_facebook = { name: 'Facebook', value: 'https://facebook.com/harriettbaldwin', url: 'https://facebook.com/harriettbaldwin' }
    card.entries.must_include harriett_twitter
    card.entries.must_include harriett_facebook
  end

  it 'should give an empty list if a member has no twitter or facebook details' do
    persons = index_at_known_sha.country('uk').legislature('commons').popolo.persons
    john = persons.select { |p| p.name == 'John Baron' }.first
    card = PersonSocial.new(person: john)
    card.entries.count.must_equal 0
  end
end
