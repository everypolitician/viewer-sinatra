# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/page/download'

describe 'Download' do
  describe 'Colombia' do
    subject do
      Page::Download.new(
        country: 'colombia',
        index:   index_at_known_sha
      )
    end

    describe 'country' do
      it 'should be Colombia' do
        subject.country.name.must_equal 'Colombia'
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

  describe 'Narnia' do
    it 'should have no country' do
      Page::Download.new(
        country: 'narnia',
        index:   index_at_known_sha
      ).country.must_be_nil
    end
  end
end
