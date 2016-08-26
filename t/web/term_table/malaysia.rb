# frozen_string_literal: true
require 'test_helper'
require_relative '../../../app'

describe 'Per Country Tests' do
  before do
    stub_everypolitician_data_request('75b7651/data/Malaysia/Dewan_Rakyat/ep-popolo-v1.0.json')
  end

  subject { Nokogiri::HTML(last_response.body) }
  let(:memtable) { subject.css('div.grid-list') }

  describe 'Malaysia' do
    before { get '/malaysia/dewan-rakyat/term-table/13.html' }

    it 'should have have its name' do
      subject.css('#term h1').text.must_include '13th Parliament of Malaysia'
    end

    it 'should list the areas' do
      memtable.text.must_include 'Samarahan, Sarawak'
    end

    it 'should show the house name in the title' do
      subject.css('.site-header__logo h3').text.must_include 'Dewan Rakyat'
    end
  end
end
