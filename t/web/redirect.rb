# frozen_string_literal: true
require 'test_helper'
require_relative '../../app'

describe 'when hitting a docs page' do
  subject { Nokogiri::HTML(last_response.body) }
  before { get '/contribute.html' }

  it 'should redirect to the right url' do
    subject.css('meta/@content').first.text.must_equal '0; url=http://docs.everypolitician.org/contribute.html'
    subject.css('link/@href').first.text.must_equal 'http://docs.everypolitician.org/contribute.html'
  end

  it 'should show the page title' do
    subject.css('.hero--jazzy h1').text.must_equal 'How to contribute'
  end

  it 'should link to the right page' do
    subject.css('.lead a/@href').text.must_equal 'http://docs.everypolitician.org/contribute.html'
    subject.css('.button--secondary/@href').text.must_equal 'http://docs.everypolitician.org/contribute.html'
  end
end
