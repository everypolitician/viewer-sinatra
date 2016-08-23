# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/page/home'

describe 'Homepage' do
  subject { Page::Home.new(index: index_at_known_sha) }

  describe 'countries' do
    it 'should include Colombian Senate' do
      co = subject.countries.find { |c| c.name == 'Colombia' }
      co.legislatures.map(&:name).must_include 'Senado'
    end
  end

  describe 'title' do
    it 'should give the country count in the title' do
      subject.title.must_include '233 countries'
    end
  end

  describe 'world' do
    it 'should sum people in Colombia' do
      colombia = subject.world.find { |c| c.name == 'Colombia' }
      colombia.total_people.must_equal 269
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
