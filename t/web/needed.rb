# frozen_string_literal: true
require 'test_helper'
require_relative '../../app'

describe 'Needed' do
  before do
    stub_request(:get, 'https://api.github.com/repos/everypolitician/everypolitician-data/issues?labels=New%20Country,To%20Find&per_page=100')
      .to_return(body: File.read('t/fixtures/github-issues-to-find.json'), headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, 'https://api.github.com/repos/everypolitician/everypolitician-data/issues?labels=New%20Country,To%20Scrape&per_page=100')
      .to_return(body: '{}', headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, 'https://api.github.com/repos/everypolitician/everypolitician-data/issues?labels=New%20Country,3%20-%20WIP&per_page=100')
      .to_return(body: '{}', headers: { 'Content-Type' => 'application/json' })
  end

  subject { Nokogiri::HTML(last_response.body) }

  describe 'when viewing the What’s Needed page' do
    before { get '/needed.html' }

    it 'should need a scraper for Eritrea' do
      last_response.body.must_include 'Eritrea'
    end
  end
end
