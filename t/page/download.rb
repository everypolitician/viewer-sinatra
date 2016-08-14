require 'minitest/autorun'
require_relative '../../lib/page/download'
require 'pry'

CJSON = 'https://cdn.rawgit.com/everypolitician/everypolitician-data/%s/countries.json'.freeze
SHA   = 'd8a4682f'.freeze

describe 'Download' do
  describe 'Colombia' do
    subject do
      # TODO: encapsulate + record this
      cjson_src = CJSON % SHA
      Everypolitician.countries_json = cjson_src
      Page::Download.new('colombia', cjson_src)
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
      Page::Download.new('narnia', CJSON % SHA).country.must_be_nil
    end
  end
end
