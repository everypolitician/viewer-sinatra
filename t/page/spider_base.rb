# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/page/spider_base'

describe 'SpiderBase' do
  subject { Page::SpiderBase.new }

  it 'has a title' do
    subject.title.must_include 'Robots'
  end

  it 'has the list of all countries' do
    subject.countries.count.must_equal 245
  end
end
