# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/page/home'

describe 'Homepage' do
  subject { Page::Home.new(index: index_at_known_sha) }

  describe 'all_countries' do
    it 'should include Colombia' do
      subject.all_countries.map(&:name).must_include 'Colombia'
    end

    it 'should include Eritrea' do
      subject.all_countries.map(&:name).must_include 'Eritrea'
    end

    it 'should include people count' do
      subject.all_countries.find { |c| c.name == 'Colombia' }.total_people.must_equal 269
    end

    it 'should have zero people if no data' do
      subject.all_countries.find { |c| c.name == 'Eritrea' }.total_people.must_equal 0
    end
  end

  describe 'countries_with_data' do
    it 'should include Colombia' do
      subject.countries_with_data.map(&:name).must_include 'Colombia'
    end

    it 'should not include Eritrea' do
      subject.countries_with_data.map(&:name).wont_include 'Eritrea'
    end
  end

  describe 'title' do
    it 'should give the country count in the title' do
      subject.title.must_include '233 countries'
    end
  end

  describe 'total_people' do
    it 'should know the person count ' do
      subject.total_people.must_equal 70_943
    end
  end

  describe 'total_statements' do
    it 'should know the statement count' do
      subject.total_statements.must_equal 3_218_179
    end
  end
end
