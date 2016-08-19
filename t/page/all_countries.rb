require 'minitest/autorun'
require_relative '../../lib/page/all_countries'

describe 'AllCountries' do
  subject { Page::AllCountries.new }

  it 'should have a World hash' do
    subject.world[:bahamas][:displayName].must_equal 'Bahamas'
  end
end
