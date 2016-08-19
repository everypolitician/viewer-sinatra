# frozen_string_literal: true
ENV['RACK_ENV'] = 'test'

require_relative '../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'Viewer' do
  subject { Nokogiri::HTML(last_response.body) }

  describe 'when viewing the home page' do
    before { get '/' }

    it 'should have show some text' do
      last_response.body.must_include 'EveryPolitician'
    end
  end

  describe 'when viewing a country home page' do
    before { get '/finland/' }

    it 'should have know its country' do
      last_response.body.must_include 'Finland'
    end

    it 'should have the country in the title' do
      subject.css('title').text.must_equal 'EveryPolitician: Finland'
    end
  end

  describe 'unknown house of known country' do
    before { get '/finland/upper' }

    it 'should have no match for Upper House of Finland' do
      last_response.status.must_equal 404
    end
  end

  describe 'country with no data' do
    before { get '/eritrea/' }

    it 'should go to no-match page for Eritrea' do
      last_response.status.must_equal 200
      last_response.body.must_include 'Sorry'
      last_response.body.must_include 'Eritrea'
    end
  end

  describe 'unknown house of unknown country' do
    before { get '/eritrea/upper' }

    it 'should have no match for Upper House of Eritrea' do
      last_response.status.must_equal 404
    end
  end

  describe 'completely unknown country' do
    before { get '/revalia/' }

    it 'should have go to no-match page for Revalia' do
      last_response.status.must_equal 404
    end
  end
end
