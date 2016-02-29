ENV['RACK_ENV'] = 'test'

require_relative '../../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'Northern Ireland' do
  subject { Nokogiri::HTML(last_response.body) }
  let(:memtable) { subject.css('.term-membership-table') }

  describe 'membership dates' do
    before { get '/northern-ireland/assembly/term-table/3.html' }

    it 'should have no dates for Adrian McQuillan' do
      subject.css('tr#mem-1074213b-e6f1-4427-bb85-176ab389a305 td').last.text.must_be :empty?
    end

    it 'should have a start date for Alastair Ross' do
      subject.css('tr#mem-c42dfdb8-647d-40db-98ce-894ca19b6aec td').last.text.must_include '2007-05-14'
      subject.css('tr#mem-c42dfdb8-647d-40db-98ce-894ca19b6aec td').last.text.wont_include '2011-03-24'
    end

    it 'should have an end date for David Simpson' do
      subject.css('tr#mem-62479dcd-b981-4a57-8a11-b8f8b17249fb td').last.text.wont_include '2007-03-09'
      subject.css('tr#mem-62479dcd-b981-4a57-8a11-b8f8b17249fb td').last.text.must_include '2010-07-01'
    end

    it 'should use the Proxy Image' do
      subject.xpath('//h3[.="Anna Lo"]/preceding-sibling::img/@src').text.must_include 'politician-image-proxy'
    end

  end
end
