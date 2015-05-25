
require 'popolo_helper'
require 'minitest/autorun'

include Popolo::Helper

describe 'Welsh Assembly' do
  subject { Popolo::Data.new('Wales') }

  describe 'party' do
    let(:orgs)    { subject.organizations }
    let(:parties) { orgs.find_all { |o| o['classification'] == 'party' } }

    it 'should have some parties' do
      parties.count.must_be :>, 1
      parties.map { |p| p['name'] }.must_include 'Plaid Cymru'
    end
  end

  describe 'legislative memberships' do
    let(:person) { subject.person_from_id('169') }

    it 'should have both executive and legislative memberships' do
      mems = subject.person_memberships(person)
      leg_mems = subject.person_legislative_memberships(person)

      mems.count.must_equal 2
      leg_mems.count.must_equal 1
      leg_mems.first['organization']['classification'].must_equal 'legislature'
      missing = (mems - leg_mems).first['organization']
      missing['classification'].must_equal 'executive'
    end
  end
end
