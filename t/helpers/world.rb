# frozen_string_literal: true
require 'minitest/autorun'
require_relative '../../lib/world'

describe 'World' do
  subject { World.new }

  it 'should know other names for countries' do
    subject.as_json[:estonia][:allNames].must_include 'Estland'
  end

  it 'should give us countries as objects' do
    subject.country('american-samoa').name.must_equal 'American Samoa'
    subject.country('american-samoa').url.must_equal 'american-samoa'
  end

  it 'should have no match for non-country' do
    subject.country('narnia').must_be_nil
  end
end
