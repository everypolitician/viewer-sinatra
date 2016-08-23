# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/page/country'

describe 'Country' do
  subject { Page::Country.new(country: index_at_known_sha.country('abkhazia')) }

  it 'has the country' do
    subject.country.name.must_equal 'Abkhazia'
  end

  it 'sets the title of the page' do
    subject.title.must_include 'Abkhazia'
  end
end
