
require 'popolo_helper'
require 'minitest/autorun'

include Popolo::Helper

describe "Welsh Assembly" do

  subject { Popolo::Data.new('wales') }

  describe "party" do

    let(:party) { subject.party_from_id('5e109a9f-5312-4602-a80a-c44950552c96') }

    it "should get the correct party" do
      party['name'].must_equal 'Plaid Cymru'
    end

  end

end
