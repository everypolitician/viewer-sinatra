# frozen_string_literal: true
require 'test_helper'
require_relative '../../../app'

describe 'Per Country Tests: Australia' do
  subject { Nokogiri::HTML(last_response.body) }

  describe 'Country page' do
    before       { get '/australia/' }
    let(:house)  { subject.css('#terms-representatives') }
    let(:senate) { subject.css('#terms-senate') }

    it 'should link to the House of Representatives' do
      house.css('a[href*="44.html"]').count.must_equal 1
    end

    it 'should link to the Senate' do
      senate.css('a[href*="/44.html"]').count.must_equal 1
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
      subject.css('title').text.must_include 'Australia'
      subject.css('title').text.must_include 'House of Representatives'
      subject.css('title').text.must_include '44th Parliament'
    end

    it 'should list the correct source' do
      subject.css('.source-credits').text.must_include 'openaustralia'
    end

    it 'should list honorific prefix in Tony Abbot bio card' do
      tony = '93e2e4cc-f5ce-4bea-be68-2fc86c38a9bc'
      subject.css("div.person-card[id=#{tony}]").text.must_include 'Honourable'
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
      subject.css('title').text.must_include 'Australia'
      subject.css('title').text.must_include 'Senate'
      subject.css('title').text.must_include '44th Parliament'
    end

    it 'should list the correct source' do
      subject.css('.source-credits').text.must_include 'openaustralia'
    end
  end
end
