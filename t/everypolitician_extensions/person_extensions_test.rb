# frozen_string_literal: true
require 'test_helper'

describe 'Everypolitician::PersonExtension' do
  describe 'accessing cabinet positions' do
    before do
      stub_popolo('f88ce37', 'Estonia/Riigikogu')
      stub_everypolitician_data_request('f88ce37/data/Estonia/Riigikogu/unstable/positions.csv')
    end

    let(:riigikogu) { index_at_known_sha.country('estonia').legislature('riigikogu') }

    subject { riigikogu.popolo.persons.find_by(name: 'Andrus Ansip') }

    it 'returns the expected number of positions' do
      subject.cabinet_memberships.size.must_equal 5
    end

    it 'returns the expected objects' do
      subject.name.must_equal 'Andrus Ansip'
      position = subject.cabinet_memberships.first
      position.label.must_equal 'Minister of Justice'
      position.start_date.must_equal Date.new(2014, 3, 26)
      position.end_date.must_equal Date.new(2015, 4, 9)
    end
  end
end
