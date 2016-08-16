require 'minitest/autorun'
require_relative '../../lib/page/country'
require 'pry'

describe 'Country' do
  let(:all_countries) do
    [
      {
        name: 'Abkhazia',
        url:  'abkhazia',
      },
    ]
  end

  let(:world) { { eritrea: {} } }

  it 'detects that a country exists' do
    page = Page::Country.new('abkhazia', all_countries, world)
    refute_nil page.country
  end

  it 'sets the title of the page if the country exists' do
    page = Page::Country.new('abkhazia', all_countries, world)
    page.title.must_include 'Abkhazia'
  end

  it 'detects that a country is missing' do
    page = Page::Country.new('eritrea', all_countries, world)
    refute_nil page.missing
  end
end
