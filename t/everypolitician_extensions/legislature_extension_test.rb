# frozen_string_literal: true
require 'test_helper'

describe 'EveryPolitician::LegislatureExtension' do
  describe 'getting cabinet positions' do
    before do
      stub_everypolitician_data_request('f88ce37/data/Estonia/Riigikogu/unstable/positions.csv')
    end

    subject { index_at_known_sha.country('Estonia').legislature('Riigikogu') }

    it 'has a list of cabinet memberships' do
      subject.cabinet_memberships.size.wont_equal 0
    end

    it 'has membership instances in the list of cabinet positions' do
      mem = subject.cabinet_memberships.first
      mem.class.must_equal EveryPolitician::LegislatureExtension::CabinetMembership
      mem.person_id.must_equal '480df40f-359a-4238-b179-332d47dd1611'
      mem.start_date.must_equal '2005-04-13'
    end
  end
end
