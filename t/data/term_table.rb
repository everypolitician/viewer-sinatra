ENV['RACK_ENV'] = 'test'

require_relative '../../app'
require 'minitest/autorun'
require 'rack/test'
require 'csv'
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

    # Then ensure the CSV for each loads OK
    countries.each do |country|
      url = "/#{country}/term_table.csv"
      get(url)
      last_response.status.must_equal 200
      last_response.header['Content-Type'].must_equal 'application/csv'
      last_response.header['Content-Disposition'].must_include country
      data = CSV.parse(last_response.body, headers: true)
      data.first.headers.must_include 'group'
      data.count.must_be :>, 1
    end

  end

end

