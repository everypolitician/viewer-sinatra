# frozen_string_literal: true
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

    it 'should not have too many seats in total' do
      seatcount.css('span.seatcount').map(&:text).map(&:to_i).reduce(&:+).must_be :<=, 101
      seatcount.css('span.seatcount').map(&:text).map(&:to_i).reduce(&:+).must_be :>=, 90
    end
  end

  describe 'Historic Finland' do
    before { get '/finland/eduskunta/term-table/35.html' }

    it 'should have 200 seats' do
      seatcount.css('span.seatcount').map(&:text).map(&:to_i).reduce(&:+).must_equal 200
    end
  end
end
