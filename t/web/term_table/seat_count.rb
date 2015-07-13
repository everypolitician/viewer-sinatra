ENV['RACK_ENV'] = 'test'

require_relative '../../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'Seat Count' do
  subject { Nokogiri::HTML(last_response.body) }
  let(:seatcount) { subject.css('#seat-count') }

  describe 'Estonia' do
    before { get '/estonia/riigikogu/term-table/13.html' }

    it 'should have have a seat count table' do
      seatcount.text.must_include 'Party Groupings'
    end

    it 'should have some seats for IRL' do
      irl = seatcount.css('li#party-IRL')
      irl.text.must_include 'Isamaa ja Res Publica Liidu'
    end

    it 'should have 101 seats' do
      seatcount.css('span.seatcount').map(&:text).map(&:to_i).reduce(&:+).must_equal 101
    end
  end
end
