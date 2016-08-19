# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/page/spider_base'

describe 'SpiderBase' do
  subject { Page::SpiderBase.new }

  it 'should have a World hash' do
    subject.world[:bahamas][:displayName].must_equal 'Bahamas'
  end
end
