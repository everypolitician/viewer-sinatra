require 'minitest/autorun'
require_relative '../../lib/page/missing_country'
require 'pry'

describe 'MissingCountry' do
  it 'has a display name' do
    page = Page::MissingCountry.new('eritrea')
    page.country.name.must_equal 'Eritrea'
  end

  it 'returns nil if country does not exist' do
    page = Page::MissingCountry.new('narnia')
    assert_nil page.country
  end
end
