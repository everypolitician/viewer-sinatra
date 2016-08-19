# frozen_string_literal: true
require 'test_helper'
require_relative '../../app'

describe 'Needed' do
  subject { Nokogiri::HTML(last_response.body) }

  describe 'when viewing the What’s Needed page' do
    before { get '/needed.html' }

    it 'should need a scraper for Eritrea' do
      last_response.body.must_include 'Eritrea'
    end
  end
end
