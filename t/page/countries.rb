# frozen_string_literal: true
require 'minitest/autorun'
require_relative '../../lib/page/countries'
require 'pry'

describe 'Countries' do
  subject { Page::Countries.new(index: index_at_known_sha) }

  it 'has a list of all countries in Everypolitician' do
    subject.countries.first.name.must_equal 'Abkhazia'
  end

  it 'has a url pointing to the correct sha' do
    subject.download_url.must_include 'd8a4682f'
  end

  it 'knows how many countries are missing' do
    subject.missing_countries.must_equal 12
  end

  it 'doesn’t have Eritrea in countries' do
    subject.countries.map(&:name).wont_include 'Eritrea'
  end
end
