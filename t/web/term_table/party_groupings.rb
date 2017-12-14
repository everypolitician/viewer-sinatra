# frozen_string_literal: true

require 'test_helper'
require_relative '../../../app'

describe 'Party Groupings section' do
  subject { Nokogiri::HTML(last_response.body) }
  let(:heading) { subject.css('.party-groupings__title h2').text }

  describe 'only Independent' do
    before do
      stub_term_table('beb21e5', 'Alderney/States')
      get '/alderney/states/term-table/2014.html'
    end

    it 'should have no party groupings (all Independent)' do
      heading.must_be_empty
    end
  end

  describe 'only Unknown' do
    before do
      stub_term_table('75b7651', 'Transnistria/Supreme_Council')
      get '/transnistria/supreme-council/term-table/6.html'
    end

    it 'should have no party groupings (all Unknown)' do
      heading.must_be_empty
    end
  end

  describe 'regular section' do
    before do
      stub_term_table('f88ce37', 'Estonia/Riigikogu')
      get '/estonia/riigikogu/term-table/13.html'
    end
    it 'should have party groupings' do
      heading.must_equal 'Party Groupings'
    end
  end
end
