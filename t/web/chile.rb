ENV['RACK_ENV'] = 'test'

require_relative '../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "Chile" do

  subject { Nokogiri::HTML(last_response.body) }

  #-------------------------------------------------------------------

  describe "when viewing the Terms page" do

    before { get '/chile/terms.html' }

    it "should have have at least 1 term" do
      subject.css('#terms ul li').count.must_be :>=, 1
    end

  end

  #-------------------------------------------------------------------

end

