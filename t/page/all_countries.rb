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
    countries = subject.world.flatten
    a = countries.each.include? :argentina
    b = countries.each.include? :belgium
    c = countries.each.include? :china
    (a & b & c).must_equal true
  end
end
