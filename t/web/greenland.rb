ENV['RACK_ENV'] = 'test'

require_relative '../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "Greenland" do

  subject { Nokogiri::HTML(last_response.body) }

  #-------------------------------------------------------------------

  describe "when viewing the Terms page" do

    before { get '/greenland/terms.html' }

    it "should have have at least 13 terms" do
      subject.css('#terms ul li').count.must_be :>=, 13
    end

    it "should go back to 1979" do
      subject.css('#terms ul li:last').text.must_include '1979'
    end

  end

  #-------------------------------------------------------------------

end

