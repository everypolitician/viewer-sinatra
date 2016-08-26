# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/subviews/person_social'
require 'everypolitician'

describe 'Social Subview' do
  subject do
    PersonSocial.new(person: index_at_known_sha.country('uk').legislature('commons')
    .popolo
    .persons
    .select { |p| p.name == 'Harriett Baldwin' }.first)
  end

  it 'should give a list of twitter and facebook details for a given member' do
    twitter = { label: 'Twitter', value: 'HBaldwinMP', url: 'http://twitter.com/HBaldwinMP' }
    facebook = { label: 'Facebook', value: 'https://facebook.com/harriettbaldwin', url: 'https://facebook.com/harriettbaldwin' }
    subject.entries.must_include twitter
    subject.entries.must_include facebook
  end
end
