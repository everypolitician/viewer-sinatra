# frozen_string_literal: true

require 'test_helper'
require_relative '../../app'

class WikidataWebTest < Minitest::CapybaraWebkitSpec
  describe 'Croatia' do
    subject { Nokogiri::HTML(last_response.body) }
    let(:yays) { subject.xpath('//h2[.="With"]/following-sibling::ol[1]/li') }
    let(:nays) { subject.xpath('//h2[.="Without"]/following-sibling::ol[1]/li') }

    before do
      stub_popolo('6e39048', 'Croatia/Sabor')
      get '/croatia/sabor/wikidata'
    end

    it 'should have people with Wikidata' do
      yays.count.must_equal 51
    end

    it 'should have people without Wikidata' do
      nays.count.must_equal 236
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

  describe 'seat count' do
    before do
      stub_popolo('6e39048', 'Croatia/Sabor')
      stub_popolo('87859a2', 'New_Zealand/House')
      stub_popolo('90decc1', 'India/Lok_Sabha')
      Capybara.current_driver = Capybara.javascript_driver
    end

    it 'should be displayed when data is available' do
      visit '/croatia/sabor/wikidata'

      page.must_have_content '151 seats'
    end

    it "should display message when there's no data" do
      visit '/new-zealand/house/wikidata'

      page.must_have_content 'Number of seats unknown in Wikidata item'
    end

    it 'should display multiple seat count values' do
      visit '/india/lok-sabha/wikidata'

      page.must_have_content '2 seat count values in Wikidata: 543, 545'
    end
  end
end
