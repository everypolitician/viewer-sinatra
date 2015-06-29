ENV['RACK_ENV'] = 'test'

require_relative '../../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'Per Country Tests' do
  subject { Nokogiri::HTML(last_response.body) }
  let(:memtable) { subject.css('.term-membership-table') }

  describe 'Australia' do
    before { get '/australia/term-table/44.html' }

    it 'should include a Representative' do
      subject.at_css('#house-representatives tr#mem-EZ5 td:first')
        .text.must_include 'Tony Abbott'
    end

    it 'should not include any Senators' do
      subject.css('#house-senate').count.must_equal 0
    end

    it 'should not have a button with the house name' do
      subject.css('a.button').text.downcase.wont_include 'senate'
    end

    it 'should have the correct page title' do
      subject.css('title').text.must_equal '44th Parliament'
    end

    it 'should list the correct source' do
      subject.css('.source-credits').text.must_include 'openaustralia'
    end
  end
end
