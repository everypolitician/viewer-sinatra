ENV['RACK_ENV'] = 'test'

require_relative '../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "Basic loads" do

  it "should be able to load every country" do
    
    # Get the list of countries on the homepage
    frontpage = get('/')
    countries = Nokogiri::HTML(last_response.body).css('#home ul.grid-list li a').map { |n|
      n.attr('href').split('/')[1]
    }

    # Then ensure the current term table for each loads OK
    countries.each do |country|
      url = "/#{country}/term_table"
      get(url)
      last_response.status.must_equal 200
      noko = Nokogiri::HTML(last_response.body)
      noko.css('table th').text.must_include 'Name'
    end

  end

end

# Country-specific tests for edge cases


describe "Per Country Tests" do

  subject { Nokogiri::HTML(last_response.body) }

  describe "Finland" do

    before { get '/finland/term_table/35' }

    it "should have have its name" do
      subject.css('#term h1').text.must_include 'Eduskunta 35 (2007)'
    end

    it "should list the parties" do
      subject.css('#term table').text.must_include 'Finnish Centre Party'
    end

    it "should list the areas" do
      subject.css('#term table').text.must_include 'Oulun'
    end

    it "shouldn't show any dates for Mikko Kuoppa" do
      subject.css('tr#mem-444').text.wont_include '20'
    end

    it "should show early departure date for Matti Vanhanen" do
      subject.css('tr#mem-414 td:last').text.must_include '2010-09-19'
    end

    it "should show late start date for Risto Kuisma" do
      subject.css('tr#mem-473 td:last').text.must_include '2010-07-13'
    end

    it "should have two rows for Merikukka Forsius" do
      # Changed Party mid-term, so one entry per party
      subject.at_css('tr#mem-560 td:first').attr('rowspan').to_i.must_equal 2
    end

    it "should link to 34" do
      subject.css('a[href*="/term_table/34"]').count.must_be :>=, 1
    end

    it "should link to 36" do
      subject.css('a[href*="/term_table/36"]').count.must_be :>=, 1
    end

    it "shouldn't link to 33" do
      subject.css('a[href*="/term_table/33"]').count.must_equal 0
    end

  end

  describe "Australia" do

    before { get '/australia/term_table/' }

    it "should include a Representative" do
      subject.at_css('tr#mem-EZ5 td:first').text.must_include 'Tony Abbott'
    end

    it "should include a Senator" do
      subject.at_css('tr#mem-GB6 td:first').text.must_include 'Jacinta Collins'
    end

  end

end

