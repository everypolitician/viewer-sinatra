# frozen_string_literal: true
require 'test_helper'
require_relative '../../app'

describe 'Wikidata' do
  subject { Nokogiri::HTML(last_response.body) }
  let(:yays) { subject.xpath('//h2[.="With"]/following-sibling::ol[1]/li') }
  let(:nays) { subject.xpath('//h2[.="Without"]/following-sibling::ol[1]/li') }

  describe 'Croatia' do
    before do
      stub_popolo('Croatia/Sabor')
      get '/croatia/sabor/wikidata'
    end

    it 'should have people with Wikidata' do
      yays.count.must_equal 70
    end

    it 'should have people without Wikidata' do
      nays.count.must_equal 219
    end

    it 'should have Tonino Picula with' do
      yays.text.must_include 'Tonino Picula'
      nays.text.wont_include 'Tonino Picula'
    end

    it 'should have Alen Prelec without' do
      nays.text.must_include 'Alen Prelec'
      yays.text.wont_include 'Alen Prelec'
    end
  end
end
