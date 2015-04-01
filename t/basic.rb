ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'minitest/autorun'
require 'rack/test'
include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "Stance viewer" do

  describe "when viewing the home page" do

    before { get '/' }

    it "should have show some text" do
      last_response.body.must_include 'PopIt Viewer'
    end

  end

  #-------------------------------------------------------------------

  describe "when viewing the MP list page" do

    before { get '/people.html' }

    it "should have Alexander Stubb" do
      last_response.body.must_include 'Stubb Alexander'
    end
  end

  #-------------------------------------------------------------------

  describe "when viewing an MP page" do

    before { get '/person/1031' }

    it "should have have their name" do
      last_response.body.must_include 'Stubb Alexander'
    end

  end

  #-------------------------------------------------------------------

  describe "when viewing an Party page" do

    before { get '/party/kok' }

    it "should have have their name" do
      last_response.body.must_include 'National Coalition Party'
    end

  end

  #-------------------------------------------------------------------

end

