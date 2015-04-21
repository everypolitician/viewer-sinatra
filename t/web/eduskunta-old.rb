ENV['RACK_ENV'] = 'test'

require_relative '../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "Stance viewer" do

  subject { Nokogiri::HTML(last_response.body) }

  #-------------------------------------------------------------------

  describe "when viewing the MP list page" do

    before { get '/eduskunta/people.html' }

    it "should have Alexander Stubb" do
      subject.css('#people ul').inner_html.must_include 'Stubb Alexander'
    end
  end

  #-------------------------------------------------------------------

  describe "when viewing the Term list page" do

    before { get '/finland/terms.html' }

    it "should have at least 35 terms" do
      subject.css('#terms ul li').count.must_be :>, 35
    end

    it "should have the first term last" do
      subject.css('#terms ul li:last').text.must_include 'Eduskunta 1 (1907)'
    end

  end

  #-------------------------------------------------------------------

  describe "when viewing the Party list page" do

    before { get '/Finland/parties.html' }

    it "should have Left Alliance" do
      subject.css('#parties ul').inner_html.must_include 'Left Alliance'
    end

    it "should not have Eduskunta" do
      subject.css('#parties ul').inner_html.wont_include 'Eduskunta'
    end

  end

  #-------------------------------------------------------------------

  describe "when viewing Person 1031" do

    before { get '/fi/person/1031' }

    it "should have have their name" do
      subject.css('h1').text.must_equal 'Stubb Alexander'
    end

    it "should have have their party membership" do
      subject.css('ul li').inner_html.must_include 'National Coalition Party'
    end

  end

  #-------------------------------------------------------------------

  describe "when viewing Person 910615" do

    before { get '/FINLAND/person/910615' }

    # This differs from 'eduskunta'
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

    before { get '/FI/term/27' }

    it "should have have its name" do
      subject.css('h1').text.must_equal 'Eduskunta 27 (1975 II)'
    end

  end

  #-------------------------------------------------------------------

  describe "when viewing an Party page" do

    before { get '/EdusKunta/party/kok' }

    it "should have have their name" do
      subject.css('h1').text.must_equal 'National Coalition Party'
    end

    it "should have many MPs" do
      subject.css('#party ul li').count.must_be :>, 20
    end

    it "should include Stubb" do
      subject.css('#party ul li').text.must_include 'Stubb Alexander'
    end

  end

  #-------------------------------------------------------------------

end

