ENV['RACK_ENV'] = 'test'

require_relative '../../app'
require 'minitest/autorun'
require 'rack/test'
require 'json'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'countries.json' do
  it 'should be able to get a list of countries' do
    get('/countries.json')
    data = JSON.parse(last_response.body)
    estonia = data.find { |c| c['name'] == 'Estonia' }
    estonia['url'].must_equal '/estonia'
    estonia['code'].must_equal 'EE'
    estonia['latest_term_csv'].must_include 'riigikogu_xiii.csv'
  end

  it 'should have non-standard country-codes' do
    get('/countries.json')
    data = JSON.parse(last_response.body)
    estonia = data.find { |c| c['name'] == 'Kosovo' }
    estonia['code'].must_equal 'XK'
  end

  it 'should know where the Popolo JSON lives' do
    get('/countries.json')
    data = JSON.parse(last_response.body)
    nz = data.find { |c| c['name'] == 'New Zealand' }
    nz['url'].must_equal '/new_zealand'
    nz['popolo'].must_match %r{/data/\w+-New_Zealand.json}
  end
end
