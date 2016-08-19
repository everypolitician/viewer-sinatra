# frozen_string_literal: true
require 'test_helper'
require_relative '../../../app'

describe 'Party Groupings section' do
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
