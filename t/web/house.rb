# frozen_string_literal: true
require 'test_helper'
require_relative '../../app'

describe 'House Page' do
  subject { Nokogiri::HTML(last_response.body) }
  before { get '/united-states-of-america/senate/' }

  describe 'list of terms' do
    it 'displays all terms' do
      subject.css('.avatar-unit').count.must_equal 18
    end

    it 'displays the last term name' do
      subject.css('.avatar-unit h3').first.text.must_equal '114th Congress'
    end

    it 'displays the first term dates' do
      subject.css('.avatar-unit p').last.text.must_equal '1981-01-06 - 1983-01-03'
    end
  end
end
