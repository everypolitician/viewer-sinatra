# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/page/missing_country'

describe 'MissingCountry' do
  it 'has a display name' do
    page = Page::MissingCountry.new(country: 'eritrea')
    page.country.name.must_equal 'Eritrea'
  end

  it 'returns nil if country does not exist' do
    page = Page::MissingCountry.new(country: 'narnia')
    assert_nil page.country
  end
end
