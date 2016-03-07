ENV['RACK_ENV'] = 'test'

require_relative '../../../app'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'Per Country Tests: Australia' do
  subject { Nokogiri::HTML(last_response.body) }

  describe 'Country page' do
    before { get '/australia/' }

    it 'should link to the House of Representatives' do
      subject.css('#terms-representatives a[href*="/44.html"]').count.must_equal 1
    end

    it 'should link to the Senate' do
      subject.css('#terms-senate a[href*="/44.html"]').count.must_equal 1
    end
  end

  describe 'Representatives' do
    before { get '/australia/representatives/term-table/44.html' }

    it 'should include a Representative' do
      subject.css('div.grid-list').text.must_include 'Tony Abbott'
    end

    it 'should not include any Senators' do
      subject.css('div.grid-list').text.wont_include 'Alan Eggleston'
    end

    it 'should have the correct page title' do
      subject.css('title').text.must_equal '44th Parliament'
    end

    it 'should list the correct source' do
      subject.css('.source-credits').text.must_include 'openaustralia'
    end
  end

  describe 'Senate' do
    before { get '/australia/senate/term-table/44.html' }

    it 'should include a Senator' do
      subject.css('div.grid-list').text.must_include 'Alan Eggleston'
    end

    it 'should not include any Representatives' do
      subject.css('div.grid-list').text.wont_include 'Tony Abbott'
    end

    it 'should have the correct page title' do
      subject.css('title').text.must_equal '44th Parliament'
    end

    it 'should list the correct source' do
      subject.css('.source-credits').text.must_include 'openaustralia'
    end
  end

end
