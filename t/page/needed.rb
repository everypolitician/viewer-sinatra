require_relative '../../lib/page/needed'
require 'minitest/autorun'
require 'pry'
require 'vcr'

describe 'Needed' do
  subject do
    Page::Needed.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
  end

  it 'should raise an error if no access token is passed' do
    proc { Page::Needed.new }.must_raise ArgumentError
  end

  it 'should return a list of countries to find' do
    VCR.use_cassette('octokit - test to_find') do
      list = subject.to_find
      a = list.map(&:title).include? 'Eritrea'
      b = list.map(&:title).include? 'Cuba'
      c = list.map(&:title).include? 'Qatar'
      (a & b & c).must_equal true
    end
  end

  it 'should return an empty list if there is nothing to scrape' do
    VCR.use_cassette('octokit - test to_scrape') do
      subject.to_scrape.size.must_equal 0
    end
  end

  it 'should return an empty list if there is nothing to finish' do
    VCR.use_cassette('octokit - test to_finish') do
      subject.to_finish.size.must_equal 0
    end
  end
end
