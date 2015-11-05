ENV['RACK_ENV'] = 'test'

require_relative '../../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'Per Country Tests' do
  subject { Nokogiri::HTML(last_response.body) }
  let(:memtable) { subject.css('.term-membership-table') }

  describe 'Finland' do
    before { get '/finland/eduskunta/term-table/35.html' }

    it 'should have have its name' do
      subject.css('#term h1').text.must_include 'Eduskunta 35'
    end

    it 'should have the correct page title' do
      subject.css('title').text.must_equal 'Eduskunta 35'
    end

    it 'should list the parties' do
      memtable.text.must_include 'Keskusta'
    end

    it 'should list the areas' do
      memtable.text.must_include 'Oulun'
    end

    it "shouldn't show any dates for Mikko Kuoppa" do
      memtable.css('tr#mem-44b4a448-f9a7-47f0-abbb-79858799f58f').text.wont_include '20'
    end

    it 'should show early departure date for Matti Vanhanen' do
      memtable.css('tr#mem-5276efaf-c4e5-424b-ac69-571b74d80f8c td:last').text.must_include '2010-09-19'
    end

    it 'should show late start date for Risto Kuisma' do
      memtable.css('tr#mem-7dd1ad94-d204-4d0f-aa3e-9762cbab7c9f td:last').text.must_include '2010-07-13'
    end

    it 'should have two rows for Merikukka Forsius' do
      # Changed Party mid-term, so one entry per party
      memtable.at_css('tr#mem-c1db6bc0-601c-4c8c-b8be-7b0898bacdbf td:first').attr('rowspan').to_i.must_equal 2
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
