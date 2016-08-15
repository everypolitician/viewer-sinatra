require_relative '../../lib/page/needed'
require 'minitest/autorun'
require 'octokit'
require 'pry'

describe 'Needed' do
  subject do
    Page::Needed.new
  end

  it 'should return a list of countries labeled to_find' do
    list = subject.to_find
    labels = ['New Country', 'To Find']
    labels.must_include list.first[:labels].first[:name]
  end

  it 'should return a list of countries to_scrape' do
    subject.to_scrape.size.must_equal 0
  end

  it 'should return a list of countries labeled "New Country,3 - WIP"' do
    subject.to_finish.size.must_equal 0
  end
end
