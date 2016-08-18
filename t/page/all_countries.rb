require 'minitest/autorun'
require_relative '../../lib/page/all_countries'

describe 'AllCountries' do
  subject do
    Page::AllCountries.new
  end

  it 'should return an array' do
    subject.world.must_be_instance_of Array
  end

  it 'should return a list of countries' do
    countries = subject.world
    bahamas = [:bahamas, { displayName: 'Bahamas', allNames: 'Bahamas バハマ Bahama’s' }]
    paraguay = [:paraguay, { displayName: 'Paraguay', allNames: 'Paraguay パラグアイ' }]
    countries.must_include bahamas
    countries.must_include paraguay
  end
end
