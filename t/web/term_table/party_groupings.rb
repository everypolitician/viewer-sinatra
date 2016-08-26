# frozen_string_literal: true
require 'test_helper'
require_relative '../../../app'

describe 'Party Groupings section' do
  before do
    stub_everypolitician_data_request('beb21e5/data/Alderney/States/ep-popolo-v1.0.json')
    stub_everypolitician_data_request('f88ce37/data/Estonia/Riigikogu/ep-popolo-v1.0.json')
    stub_everypolitician_data_request('75b7651/data/Transnistria/Supreme_Council/ep-popolo-v1.0.json')
  end

  subject { Nokogiri::HTML(last_response.body) }
  let(:heading) { subject.css('.party-groupings__title h2').text }

  describe 'only Independent' do
    before { get '/alderney/states/term-table/2014.html' }
    it 'should have no party groupings (all Independent)' do
      heading.must_be_empty
    end
  end

  describe 'only Unknown' do
    before { get '/transnistria/supreme-council/term-table/6.html' }
    it 'should have no party groupings (all Unknown)' do
      heading.must_be_empty
    end
  end

  describe 'regular section' do
    before { get '/estonia/riigikogu/term-table/13.html' }
    it 'should have party groupings' do
      heading.must_equal 'Party Groupings'
    end
  end
end
