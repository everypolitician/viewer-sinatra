# frozen_string_literal: true

require_relative '../../lib/page/needed'
require 'test_helper'

describe 'Needed' do
  subject do
    stub_github_api
    Page::Needed.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
  end

  it 'should know that Eritrea is missing' do
    assert subject.to_find.map(&:title).include? 'Eritrea'
  end

  it 'should order the list of countries to find by name' do
    wanted = subject.to_find.map(&:title)
    assert wanted == wanted.sort
  end

  # Might be good to have a version of these tests against a different
  # cassette, when we have something in these, but Good Enough For Now
  it 'should currently have nothing to scrape' do
    subject.to_scrape.size.must_equal 0
  end

  it 'should currently have nothing to finish' do
    subject.to_finish.size.must_equal 0
  end
end
