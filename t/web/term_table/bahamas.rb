# frozen_string_literal: true
require 'test_helper'
require_relative '../../../app'

describe 'Bahamas' do
  subject { Nokogiri::HTML(last_response.body) }

  before do
    stub_popolo('4da60b8', 'Bahamas/House_of_Assembly')
    get '/bahamas/house-of-assembly/term-table/2012.html'
  end

  describe 'source urls' do
    it 'links to a valid url' do
      subject.css('.source-credits p:first-child a').last.text.must_include '/Members of Parliament/'
    end

    it 'displays an unescaped url' do
      subject.css('.source-credits p:first-child a/@href').last.text.must_include '/Members+of+Parliament/'
    end
  end
end
