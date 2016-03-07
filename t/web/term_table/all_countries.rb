ENV['RACK_ENV'] = 'test'

require_relative '../../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'Basic loads' do
  it 'should be able to load every country' do
    # Get the list of countries on the homepage
    get '/countries.html'
    countries = Nokogiri::HTML(last_response.body)
                .css('#countries ul.grid-list li a/@href')
                .map(&:text)

    countries.wont_be :empty?

    # Then get the front page for each
    countries.each do |country|
      puts "Testing #{country}"
      get country
      last_response.status.must_equal 200
      noko = Nokogiri::HTML(last_response.body)
      terms = noko.css('a[href*="/term-table/"]/@href').map(&:text)
      terms.size.wont_be :zero?

      # Then make sure each term for each loads
      get terms.first
      last_response.status.must_equal 200
      noko = Nokogiri::HTML(last_response.body)

      # Make sure we have at least 5 cards 
      noko.css('.person-card').count.must_be :>=, 5
    end
  end
end
