# frozen_string_literal: true
require 'test_helper'
require_relative '../../app'

describe 'Tab component in term table' do
  subject { Nokogiri::HTML(last_response.body) }

  before do
    stub_everypolitician_data_request('6139efe/data/Australia/Representatives/ep-popolo-v1.0.json')
    get '/australia/representatives/term-table/44.html'
  end

  it 'should have as many tabs as houses' do
    subject.css('.house-tab').count.must_equal 2
  end

  describe 'active tab' do
    it 'should be the House of Representatives' do
      subject.css('.house-tab--active').text.strip.must_equal 'House of Representatives'
    end
  end

  describe 'tab links' do
    let(:tabs) { subject.css('.house-tab/@href') }

    it 'links to first term in House of Representatives' do
      tabs.first.text.must_equal '/australia/representatives/term-table/44.html'
    end

    it 'links to first term in Senate' do
      tabs.last.text.must_equal '/australia/senate/term-table/44.html'
    end
  end
end
