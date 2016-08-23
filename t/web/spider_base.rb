# frozen_string_literal: true
require 'test_helper'
require_relative '../../app'

describe 'SpiderBase' do
  subject { Nokogiri::HTML(last_response.body) }

  describe 'when viewing the status/all_countries page' do
    before { get '/status/all_countries.html' }

    it 'has every link pointing to that country’s slug' do
      subject.css('.grid-list a/@href').first.text.must_equal '/abkhazia/'
    end

    it 'has every list item displaying that country’s name' do
      subject.css('.grid-list h3').first.text.must_equal 'Abkhazia'
    end
  end
end
