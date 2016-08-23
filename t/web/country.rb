# frozen_string_literal: true
require 'test_helper'
require_relative '../../app'

describe 'Country Page' do
  subject { Nokogiri::HTML(last_response.body) }
  let(:terms) { subject.css('#terms-riigikogu li') }

  describe 'when viewing a country home page' do
    before { get '/estonia/' }

    it 'should know its country' do
      subject.css('.site-header__logo h2').text.strip.must_equal 'Estonia'
    end

    it 'should have the country in the title' do
      subject.css('title').text.must_equal 'EveryPolitician: Estonia'
    end

    it 'should have two terms' do
      terms.count.must_equal 2
    end

    it 'should have start+end dates for the oldest term' do
      terms.css('p').first.text.must_equal '2015-03-30 - '
    end

    it 'should have no end date for the most recent term' do
      terms.css('p').last.text.must_equal '2011-03-27 - 2015-03-23'
    end
  end
end
