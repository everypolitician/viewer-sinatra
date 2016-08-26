# frozen_string_literal: true
require 'test_helper'
require_relative '../../../app'

describe 'Seat Count' do
  subject     { Nokogiri::HTML(last_response.body) }
  let(:seats) { subject.css('#seat-count') }
  let(:total) { seats.css('.seatcount').map(&:text).map(&:to_i).reduce(&:+) }

  describe 'Estonia' do
    before do
      stub_everypolitician_data_request('f88ce37/data/Estonia/Riigikogu/ep-popolo-v1.0.json')
      get '/estonia/riigikogu/term-table/13.html'
    end

    it 'should have have a seat count table' do
      seats.text.must_include 'Party Groupings'
    end

    it 'should have some seats for IRL' do
      irl = seats.css('li#party-IRL')
      irl.text.must_include 'Isamaa ja Res Publica Liidu'
    end

    it 'should have 101 seats' do
      total.must_equal 101
    end
  end

  describe 'Historic Finland' do
    before do
      stub_everypolitician_data_request('ba4fa22/data/Finland/Eduskunta/ep-popolo-v1.0.json')
      get '/finland/eduskunta/term-table/35.html'
    end

    it 'should have 200 seats' do
      total.must_equal 200
    end
  end
end
