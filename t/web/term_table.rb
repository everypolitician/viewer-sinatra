ENV['RACK_ENV'] = 'test'

require_relative '../../app'
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

# Country-specific tests for edge cases

describe 'Per Country Tests' do
  subject { Nokogiri::HTML(last_response.body) }
  let(:memtable) { subject.css('.term-membership-table') }

  describe 'Finland' do
    before { get '/finland/term_table/35.html' }

    it 'should have have its name' do
      subject.css('#term h1').text.must_include 'Eduskunta 35 (2007)'
    end

    it 'should have the correct page title' do
      subject.css('title').text.must_equal 'Eduskunta 35 (2007)'
    end

    it 'should list the parties' do
      memtable.text.must_include 'Centre Party'
    end

    it 'should list the areas' do
      memtable.text.must_include 'Oulun'
    end

    it "shouldn't show any dates for Mikko Kuoppa" do
      memtable.css('tr#mem-444').text.wont_include '20'
    end

    it 'should show early departure date for Matti Vanhanen' do
      memtable.css('tr#mem-414 td:last').text.must_include '2010-09-19'
    end

    it 'should show late start date for Risto Kuisma' do
      memtable.css('tr#mem-473 td:last').text.must_include '2010-07-13'
    end

    it 'should have two rows for Merikukka Forsius' do
      # Changed Party mid-term, so one entry per party
      memtable.at_css('tr#mem-560 td:first').attr('rowspan').to_i.must_equal 2
    end

    it 'should link to 34' do
      subject.css('a[href*="/term_table/34"]').count.must_be :>=, 1
    end

    it 'should link to 36' do
      subject.css('a[href*="/term_table/36"]').count.must_be :>=, 1
    end

    it "shouldn't link to 33" do
      subject.css('a[href*="/term_table/33"]').count.must_equal 0
    end

    it "shouldn't have a button for the house name" do
      subject.css('a.button').text.downcase.wont_include 'eduskunta'
    end
  end

  describe 'Australia' do
    before { get '/australia/term_table/44.html' }

    it 'should include a Representative' do
      subject.at_css('#house-representatives tr#mem-EZ5 td:first')
        .text.must_include 'Tony Abbott'
    end

    it 'should include a Senator' do
      subject.at_css('#house-senate tr#mem-GB6 td:first')
        .text.must_include 'Jacinta Collins'
    end

    it 'should have a button with the house name' do
      subject.css('a.button').text.downcase.must_include 'senate'
    end

    it 'should have the correct page title' do
      subject.css('title').text.must_equal '44th Parliament'
    end

    it 'should list the correct source' do
      subject.css('.source-credits').text.must_include 'openaustralia'
    end
  end

  describe 'Canada' do
    before { get '/canada/term_table/41.html' }

    it 'should have three parties with 2 seats' do
      doubles = subject.xpath('//p[contains(.,"2 seats")]/../h3').map(&:text)
      doubles.count.must_equal 3
      doubles.first.must_equal 'Bloc Québécois'
      doubles.last.must_equal 'Green Party'
    end
  end
end
