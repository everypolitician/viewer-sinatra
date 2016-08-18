require 'minitest/autorun'
require_relative '../../lib/page/all_countries'

describe 'AllCountries' do
  subject do
    Page::AllCountries.new
  end

  it 'should return an hash' do
    subject.world.must_be_instance_of Hash
  end

  it 'should return a list of countries' do
    countries = subject.world
    bahamas = { displayName: 'Bahamas', allNames: 'Bahamas バハマ Bahama’s' }
    paraguay = { displayName: 'Paraguay', allNames: 'Paraguay パラグアイ' }
    countries[:bahamas].must_equal bahamas
    countries[:paraguay].must_equal paraguay
  end
end
