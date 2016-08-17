require 'minitest/autorun'
require_relative '../../lib/page/country'
require 'pry'

describe 'Country' do
  it 'detects that a country is not missing' do
    page = Page::Country.new('abkhazia')
    refute_nil page.country
  end

  it 'sets the title of the page if the country exists' do
    page = Page::Country.new('abkhazia')
    page.title.must_include 'Abkhazia'
  end

  it 'detects that a country is missing' do
    page = Page::Country.new('narnia')
    assert_nil page.country
  end
end
