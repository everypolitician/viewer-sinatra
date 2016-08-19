# frozen_string_literal: true
require 'test_helper'
require_relative '../../../app'

describe 'Per Country Tests' do
  subject { Nokogiri::HTML(last_response.body) }
  let(:memtable) { subject.css('div.grid-list') }

  describe 'New Zeland' do
    before { get '/new-zealand/house/term-table/51.html' }

    it 'should have minus, rather than underscore, in its url' do
      subject.css('#term h1').text.must_include '51st Parliament'
    end
  end
end
