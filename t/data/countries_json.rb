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
    country = data.find { |c| c['name'] == 'Estonia' }
    country['url'].must_equal '/estonia'
    country['code'].must_equal 'EE'
    country['latest_term_csv'].must_include 'riigikogu_xiii.csv'
  end

  it 'should find exact matches' do
    get('/countries.json')
    data = JSON.parse(last_response.body)
    country = data.find { |c| c['name'] == 'Niger' }
    country['code'].must_equal 'NE'
  end

  it 'should find based on starting text' do
    get('/countries.json')
    data = JSON.parse(last_response.body)
    country = data.find { |c| c['name'] == 'Moldova' }
    country['code'].must_equal 'MD'
  end

  it 'should find non-standard country-codes' do
    get('/countries.json')
    data = JSON.parse(last_response.body)
    country = data.find { |c| c['name'] == 'Kosovo' }
    country['code'].must_equal 'XK'
  end

  it 'should know where the Popolo JSON lives' do
    get('/countries.json')
    data = JSON.parse(last_response.body)
    country = data.find { |c| c['name'] == 'New Zealand' }
    country['url'].must_equal '/new_zealand'
    country['popolo'].must_match %r{raw.githubusercontent.com}
  end
end
