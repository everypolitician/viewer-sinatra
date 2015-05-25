ENV['RACK_ENV'] = 'test'

require_relative '../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'Wales' do
  subject { Nokogiri::HTML(last_response.body) }

  #-------------------------------------------------------------------

  describe 'when viewing a Person with Legislative and Executive memberships' do
    before { get '/wales/person/169' }

    it 'should have have their name' do
      subject.css('h1').text.must_equal 'David Melding'
    end

    it 'should have have their legislative membership' do
      subject.css('ul li').inner_html.must_include 'Welsh Conservative Party'
    end
  end

  #-------------------------------------------------------------------
end
