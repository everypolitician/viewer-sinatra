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

describe "countries.json" do

  it "should be able to get a list of countries" do

    get('/countries.json')
    data = JSON.parse(last_response.body)
    estonia = data.find { |c| c['name'] == 'Estonia' }
    estonia['url'].must_equal '/estonia'
    estonia['latest_term_csv'].must_include 'riigikogu_xiii.csv'
  end

end
