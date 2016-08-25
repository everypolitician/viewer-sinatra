# frozen_string_literal: true
require 'test_helper'
require_relative '../../app'

describe 'Download names.csv button' do
  subject { Nokogiri::HTML(last_response.body) }
  before { get '/united-states-of-america/download.html' }
  it 'should link to the names.csv file' do
    subject_buttons = subject.css('a.button--download/@href').map(&:value).select { |h| h.include? '/names.csv' }
    subject_buttons.must_include 'https://cdn.rawgit.com/everypolitician/everypolitician-data/735c68a/data/United_States_of_America/House/names.csv'
    subject_buttons.must_include 'https://cdn.rawgit.com/everypolitician/everypolitician-data/cb4a755/data/United_States_of_America/Senate/names.csv'
  end
end
