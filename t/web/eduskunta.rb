ENV['RACK_ENV'] = 'test'

require_relative '../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "Finland" do

  subject { Nokogiri::HTML(last_response.body) }

  #-------------------------------------------------------------------

  describe "when viewing the MP list page" do

    before { get '/finland/people.html' }

    it "should have Alexander Stubb" do
      subject.css('#people ul').inner_html.must_include 'Stubb Alexander'
    end
  end

  #-------------------------------------------------------------------

  describe "when viewing the Term list page" do

    before { get '/finland/terms.html' }

    it "should have at least 12 terms" do
      subject.css('#terms ul li').count.must_be :>=, 12
    end

    it "should go back to 1970" do
      subject.css('#terms ul li:last').text.must_include 'Eduskunta 25 (1970)'
    end

  end

  #-------------------------------------------------------------------

  describe "when viewing the Party list page" do

    before { get '/finland/parties.html' }

    it "should have Left Alliance" do
      subject.css('#parties ul').inner_html.must_include 'Left Alliance'
    end

    it "should not have Eduskunta" do
      subject.css('#parties ul').inner_html.wont_include 'Eduskunta'
    end

  end

  #-------------------------------------------------------------------

  describe "when viewing Person 1031" do

    before { get '/finland/person/1031' }

    it "should have have their name" do
      subject.css('h1').text.must_equal 'Stubb Alexander'
    end

    it "should have have their party membership" do
      subject.css('ul li').inner_html.must_include 'National Coalition Party'
    end

  end

  #-------------------------------------------------------------------

  describe "when viewing Person 910615" do

    before { get '/finland/person/910615' }

    # This differs from 'eduskunta-old'
    it "should have two legislative terms" do
      lis = subject.css('#person ul li').map { |li| li.text }
      lis.count.must_equal 3
      lis.first.must_match 'The Finns Party'
      lis.first.must_match '2011-04-20'
      lis.last.must_match 'The Finns Party'
      lis.last.must_match '1979-03-24'
      lis.last.must_match '1983-03-25'
    end

  end

  #-------------------------------------------------------------------

  describe "when viewing an Term page" do

    before { get '/finland/term/35' }

    it "should have have its name" do
      subject.css('#term h1').text.must_include 'Eduskunta 35 (2007)'
    end

    it "should list the parties" do
      subject.css('#term h2').text.must_match 'Finnish Centre Party'
    end

    it "shouldn't show any dates for Mikko Kuoppa" do
      subject.css('a[href*="444"]').text.wont_include '20'
    end

    it "should show early departure date for Matti Vanhanen" do
      subject.css('a[href*="414"]').text.must_include '2010-09-19'
    end

    it "should show late start date for Risto Kuisma" do
      subject.css('a[href*="473"]').text.must_include '2010-07-13'
    end

    it "should only have two entries for Merikukka Forsius" do
      # Changed Party mid-term, so one entry per party
      subject.css('a[href*="560"]').count.must_equal 2
    end

  end

  #-------------------------------------------------------------------

  describe "when viewing an Party page" do

    before { get '/finland/party/kok' }

    it "should have have their name" do
      subject.css('h1').text.must_equal 'National Coalition Party'
    end

    it "should have many Terms" do
      subject.css('#party ul li').count.must_be :>=, 12
    end

    it "going back to Eduskunta 25" do
      subject.css('#party ul li:last').text.must_include 'Eduskunta 25'
      subject.css('#party ul li:last').text.must_include '1 seat'
    end

  end

  #-------------------------------------------------------------------

end

