# frozen_string_literal: true
require 'test_helper'
require_relative '../../app'

describe 'Download names.csv button' do
  subject { Nokogiri::HTML(last_response.body) }
  before { get '/united-states-of-america/download.html' }

  let(:links) do
    subject.css('a.button--download/@href')
           .map(&:value)
           .select { |h| h.include? '/names.csv' }
           .join
  end

  it 'should link to the House names.csv file' do
    links.must_include '735c68a/data/United_States_of_America/House/names.csv'
  end

  it 'should link to the Senate names.csv file' do
    links.must_include 'cb4a755/data/United_States_of_America/Senate/names.csv'
  end
end
