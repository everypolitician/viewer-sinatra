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
    get '/'
    countries = Nokogiri::HTML(last_response.body)
                .css('#home ul.grid-list li a/@href')
                .map(&:text)

    # Then get the front page for each
    countries.each do |country|
      puts "Testing #{country}"
      get country
      last_response.status.must_equal 200
      noko = Nokogiri::HTML(last_response.body)
      terms = noko.css('a[href*="/term_table/"]/@href').map(&:text)
      terms.size.wont_be :zero?

      # Then get the first term for each
      # puts "GET #{terms.first}"
      get terms.first
      last_response.status.must_equal 200
      noko = Nokogiri::HTML(last_response.body)
      noko.css('table th').text.must_include 'Name'
    end
  end
end
