
require 'popolo_helper'
require 'minitest/autorun'

include Popolo::Helper

describe "People's Assembly" do

  subject { Popolo::Data.new('za') }

  describe "party" do

    it "should get the correct party" do
      puts subject.persons
      subject.persons.count.must_equal 10
    end

  end

end
