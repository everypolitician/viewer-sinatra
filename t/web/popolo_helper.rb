ENV['RACK_ENV'] = 'test'

require_relative '../../app'
require 'minitest/autorun'

describe Popolo::Helper do
  include Popolo::Helper

  describe '#number_to_millions' do
    it 'formats numbers as millions to one decimal place' do
      number_to_millions(2700000).must_equal(2.7)
    end

    it 'rounds down rather than up' do
      number_to_millions(2680000).must_equal(2.6)
    end

    it 'removes the zero for whole numbers' do
      number_to_millions(3000000).must_equal(3)
    end
  end
end
