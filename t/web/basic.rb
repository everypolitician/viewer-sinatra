ENV['RACK_ENV'] = 'test'

require_relative '../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "Stance viewer" do

  subject { Nokogiri::HTML(last_response.body) }

  describe "when viewing the home page" do

    before { get '/' }

    it "should have show some text" do
      last_response.body.must_include 'PopIt Viewer'
    end

  end

  describe "unknown country" do

    before { get '/revalia/parties.html' }

    it "should have no match for Revalia" do
      last_response.status.must_equal 404
    end
  end


end

