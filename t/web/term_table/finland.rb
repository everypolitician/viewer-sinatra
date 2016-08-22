# frozen_string_literal: true
require 'test_helper'
require_relative '../../../app'

describe 'Per Country Tests' do
  subject { Nokogiri::HTML(last_response.body) }
  let(:memtable) { subject.css('div.grid-list') }
  let(:forsius)  { memtable.css('#mem-c1db6bc0-601c-4c8c-b8be-7b0898bacdbf') }
  let(:kuisma)   { memtable.css('#mem-7dd1ad94-d204-4d0f-aa3e-9762cbab7c9f') }
  let(:kuopaa)   { memtable.css('#mem-44b4a448-f9a7-47f0-abbb-79858799f58f') }
  let(:vanhanen) { memtable.css('#mem-5276efaf-c4e5-424b-ac69-571b74d80f8c') }

  describe 'Finland' do
    before { get '/finland/eduskunta/term-table/35.html' }

    it 'should link to the country page' do
      subject.css('.site-header h2 a/@href').text.must_equal '/finland/'
    end

    it 'should have have its name' do
      subject.css('#term h1').text.must_include 'Eduskunta 35'
    end

    it 'should have the correct page title' do
      subject.css('title').text.must_include 'Finland'
      subject.css('title').text.must_include 'Eduskunta'
      subject.css('title').text.must_include 'Eduskunta 35'
    end

    it 'should list the parties' do
      memtable.text.must_include 'Keskusta'
    end

    it 'should list the areas' do
      memtable.text.must_include 'Oulun'
    end

    it "shouldn't show any dates for Mikko Kuoppa" do
      kuopaa.text.wont_include '20'
    end

    it 'should show early departure date for Matti Vanhanen' do
      vanhanen.text.must_include '2010-09-19'
    end

    it 'should show late start date for Risto Kuisma' do
      kuisma.text.must_include '2010-07-13'
    end

    it 'should have one membership section for Risto Kuisma' do
      kuisma.count.must_equal 1
    end

    it 'should have two membership sections for Merikukka Forsius' do
      forsius.css('.person-card__politics').count.must_equal 2
    end

    it 'should link to 34' do
      subject.css('a[href*="/term-table/34"]').count.must_be :>=, 1
    end

    it 'should link to 36' do
      subject.css('a[href*="/term-table/36"]').count.must_be :>=, 1
    end

    it "shouldn't link to 33" do
      subject.css('a[href*="/term-table/33"]').count.must_equal 0
    end

    it "shouldn't have a button for the house name" do
      subject.css('a.button').text.downcase.wont_include 'eduskunta'
    end
  end
end
