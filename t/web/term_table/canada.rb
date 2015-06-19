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

  describe 'Canada' do
    before { get '/canada/term_table/41.html' }

    it 'should have three parties with 2 seats' do
      doubles = subject.xpath('//p[contains(.,"2 seats")]/../h3').map(&:text)
      doubles.count.must_equal 3
      doubles.first.must_equal 'Bloc Québécois'
      doubles.last.must_equal 'Green Party'
    end
  end
end
