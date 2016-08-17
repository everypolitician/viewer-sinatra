require 'minitest/autorun'
require_relative '../../lib/page/countries'
require 'pry'

CJSON      = 'https://cdn.rawgit.com/everypolitician/everypolitician-data/%s/countries.json'.freeze
SHA        = 'd8a4682f'.freeze
datasource = CJSON % SHA

describe 'Countries' do
  subject do
    Page::Countries.new
  end

  it 'has a list of all countries in Everypolitician' do
    Everypolitician.countries_json = datasource
    subject.countries.first.name.must_equal 'Abkhazia'
  end

  it 'has a url pointing to the last version of the db' do
    Everypolitician.countries_json = datasource
    assert subject.download_url.match(datasource)
  end

  it 'has a list of all countries in the world' do
    Everypolitician.countries_json = datasource
    subject.world.length.must_equal 245
  end
end
