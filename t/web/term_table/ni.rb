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
  let(:memtable) { subject.css('div.grid-list') }

  describe 'membership dates' do
    before { get '/northern-ireland/assembly/term-table/3.html' }

    it 'should have no dates for Adrian McQuillan' do
      subject.css('#mem-1074213b-e6f1-4427-bb85-176ab389a305').last.text.wont_include '20'
    end

    it 'should have a start date for Alastair Ross' do
      subject.css('#mem-c42dfdb8-647d-40db-98ce-894ca19b6aec').last.text.must_include '2007-05-14'
      subject.css('#mem-c42dfdb8-647d-40db-98ce-894ca19b6aec').last.text.wont_include '2011-03-24'
    end

    it 'should have an end date for David Simpson' do
      subject.css('#mem-62479dcd-b981-4a57-8a11-b8f8b17249fb').last.text.wont_include '2007-03-09'
      subject.css('#mem-62479dcd-b981-4a57-8a11-b8f8b17249fb').last.text.must_include '2010-07-01'
    end

    it 'should start with a placeholder image, but have proxy set' do
      img = subject.css('#mem-39093c42-e2ef-4fc1-805f-e1eb9167111d img.person-card__image')
      img.attr('src').text.must_equal '/images/person-placeholder-108px.png'
      img.attr('data-src').text.must_include 'politician-image-proxy'
    end
  end
end
