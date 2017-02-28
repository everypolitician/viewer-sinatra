# frozen_string_literal: true
require 'test_helper'
require_relative '../../../app'

describe 'Bahamas' do
  subject { Nokogiri::HTML(last_response.body) }

  before do
    stub_term_table('4da60b8', 'Bahamas/House_of_Assembly')
    get '/bahamas/house-of-assembly/term-table/2012.html'
  end

  describe 'source urls' do
    let(:sources) { subject.css('.source-credits p:first-child') }

    it 'links to a valid url' do
      sources.css('a').last.text.must_include '/Members of Parliament/'
    end

    it 'displays an unescaped url' do
      sources.css('a/@href').last.text.must_include '/Members+of+Parliament/'
    end
  end
end
