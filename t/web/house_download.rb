# frozen_string_literal: true
require 'test_helper'
require_relative '../../app'

describe 'house download template' do
  subject { Nokogiri::HTML(last_response.body) }
  before { get '/united-states-of-america/senate/download.html' }

  describe 'headings' do
    let(:banner)       { subject.css('.page-section--grey h3').text }
    let(:house_header) { subject.css('.country__legislature__header h2').text }

    it 'shows the house name in the banner' do
      banner.must_include 'Senate'
    end

    it 'shows the country name in the banner' do
      banner.must_include 'United States of America'
    end

    it 'shows the house name in the legislature header' do
      house_header.must_include 'Senate'
    end
  end

  describe 'download links' do
    let(:all_data)  { subject.css('.country__legislature a.button--download/@href') }
    let(:last_term) { subject.css('.avatar-unit a.button--download/@href').first }

    it 'links to popolo file' do
      all_data.first.text.must_include '/United_States_of_America/Senate/ep-popolo-v1.0.json'
    end

    it 'links to the names file' do
      all_data[1].text.must_include '/United_States_of_America/Senate/names.csv'
    end

    it 'links to the term file' do
      last_term.text.must_include '/United_States_of_America/Senate/term-114.csv'
    end
  end

  describe 'term information' do
    it 'shows the right name' do
      subject.css('#term-senate-114 h3').text.must_include '114th Congress'
    end

    it 'shows the right dates' do
      subject.css('#term-senate-114 p').text.must_include '2015-01-06'
    end
  end
end
