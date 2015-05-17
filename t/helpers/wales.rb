
require 'popolo_helper'
require 'minitest/autorun'

include Popolo::Helper

describe "Welsh Assembly" do

  subject { Popolo::Data.new('Wales') }

  describe "party" do

    let(:party) { subject.organizations.find { |o| o['name'] == 'Plaid Cymru' } }

    it "should get find a party" do
      party['classification'].must_equal 'party'
    end
  end

  describe "legislative memberships" do

    let(:person) { subject.person_from_id('169') }

    it "should have both executive and legislative memberships" do
      mems = subject.person_memberships(person)
      leg_mems = subject.person_legislative_memberships(person)

      mems.count.must_equal 2
      leg_mems.count.must_equal 1
      leg_mems.first['organization']['classification'].must_equal 'legislature'
      (mems - leg_mems).first['organization']['classification'].must_equal 'executive'

    end

  end

end
