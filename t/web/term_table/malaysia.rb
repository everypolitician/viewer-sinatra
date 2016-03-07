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
  let(:memtable) { subject.css('div.grid-list') }

  describe 'Malaysia' do
    before { get '/malaysia/dewan-rakyat/term-table/13.html' }

    it 'should have have its name' do
      subject.css('#term h1').text.must_include '13th Parliament of Malaysia'
    end

    it 'should list the areas' do
      memtable.text.must_include 'Samarahan, Sarawak'
    end
  end
end
