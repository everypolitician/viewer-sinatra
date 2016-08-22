# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/world'

describe 'World' do
  subject { World.new }

  it 'should know other names for countries' do
    subject.as_json[:estonia][:allNames].must_include 'Estland'
  end

  it 'should give us countries as objects' do
    subject.country('american-samoa').name.must_equal 'American Samoa'
    subject.country('american-samoa').slug.must_equal 'american-samoa'
  end

  it 'should have no match for non-country' do
    subject.country('narnia').must_be_nil
  end

  it 'has a list of countries sorted alphabetically by name' do
    subject.countries.first.name.must_equal 'Abkhazia'
    subject.countries.last.name.must_equal  'Åland Islands'
  end
end
