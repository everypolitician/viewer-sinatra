require 'minitest/autorun'
require_relative '../../lib/page/country'
require 'pry'

SHA = 'd8a4682f'.freeze

describe 'Country' do
  it 'an existing country has a name' do
    page = Page::Country.new('Abkhazia', SHA)
    page.country.name.must_equal 'Abkhazia'
  end

  it 'sets the title of the page if the country exists' do
    page = Page::Country.new('Abkhazia', SHA)
    page.title.must_include 'Abkhazia'
  end

  it 'detects that a country is missing' do
    page = Page::Country.new('narnia', SHA)
    assert_nil page.country
  end
end
