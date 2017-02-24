# frozen_string_literal: true
require 'test_helper'

describe 'Everypolitician::LegislativePeriodExtension' do
  describe 'getting cabinet positions' do
    before do
      stub_everypolitician_data_request('f88ce37/data/Estonia/Riigikogu/unstable/positions.csv')
    end

    subject { index_at_known_sha.country('Estonia').legislature('Riigikogu').term('13') }

    it 'only returns cabinet positions for the legislative period' do
      mem = subject.cabinet_memberships.first
      mem.start_date.must_be :>=, subject.start_date.to_s
    end
  end
end
