# frozen_string_literal: true
require 'minitest/autorun'
require_relative '../../lib/page/country'

describe 'Country' do
  subject { Page::Country.new(country: 'abkhazia', index: index_at_known_sha) }

  it 'has the country' do
    subject.country.name.must_equal 'Abkhazia'
  end

  it 'sets the title of the page' do
    subject.title.must_include 'Abkhazia'
  end

  it 'detects that a country is missing' do
    Page::Country.new(
      country: 'narnia',
      index:   index_at_known_sha
    ).country.must_be_nil
  end
end
