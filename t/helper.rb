
require 'popolo_helper'
require 'minitest/autorun'

include Popolo::Helper

describe "party" do

  subject { party_from_id('kok') }

  it "should get the correct party" do
    subject['name'].must_equal 'National Coalition Party'
  end

end

describe "person" do

  subject { person_from_id('1031') }

  it "should get the correct person" do
    subject['name'].must_equal 'Stubb Alexander'
  end

end

describe "term" do

  subject { term_from_id('34') }

  it "should get the correct term" do
    subject['name'].must_equal 'Eduskunta 34 (2003)'
  end

end

