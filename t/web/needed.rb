ENV['RACK_ENV'] = 'test'

require_relative '../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'Needed' do
  subject { Nokogiri::HTML(last_response.body) }

  describe "when viewing the What’s Needed page" do
    before { get '/needed.html' }

    it 'should need a scraper for the Vatican' do
      last_response.body.must_include 'Vatican City'
    end
  end

end
