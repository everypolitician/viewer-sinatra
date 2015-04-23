ENV['RACK_ENV'] = 'test'

require_relative '../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "Viewer" do

  subject { Nokogiri::HTML(last_response.body) }

  describe "magic sinatra routes" do

    before { get '/__sinatra__/500.png' }

    it "should pass __sinatra__ requests through" do
      last_response.status.must_equal 200
    end
  end
  

end

