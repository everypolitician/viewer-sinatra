# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/page/house_download'

describe 'HouseDownload' do
  subject do
    country = index_at_known_sha.country('united-states-of-america')
    house   = country.legislature('senate')
    Page::HouseDownload.new(
      house: house,
      index: index_at_known_sha
    )
  end

  describe 'country' do
    it 'should be the US' do
      subject.country.name.must_equal 'United States of America'
    end
  end

  describe 'house' do
    it 'should be the Senate' do
      subject.house.name.must_equal 'Senate'
    end
  end

  describe 'title' do
    it 'should contain the country name' do
      subject.title.must_include 'United States of America'
    end

    it 'should contain the house name' do
      subject.title.must_include 'Senate'
    end
  end

  describe 'legislative_periods' do
    it 'should contain the 114th congress period' do
      subject.legislative_periods.first.slug.must_equal '114'
    end
  end

  describe 'download_url' do
    it 'should be at the correct SHA' do
      subject.download_url.must_include 'd8a4682f'
    end

    it 'should be at rawgit' do
      subject.download_url.must_include 'cdn.rawgit.com'
    end
  end
end
