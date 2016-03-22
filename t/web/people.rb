ENV['RACK_ENV'] = 'test'

require_relative '../../lib/people'

require 'minitest/autorun'

describe People do
  describe 'Collection' do
    subject { People::Collection.new(popolo, ['1']) }
    let(:popolo) do
      EveryPolitician::Popolo::JSON.new(
        persons: [
          { name: 'Bob', id: '1' }
        ],
        memberships: [
          {
            person_id: '1',
            legislative_period_id: '42',
            start_date: '2010-06-01',
            end_date: '2015-05-22',
            area_id: '123',
            on_behalf_of_id: '456'
          }
        ],
        areas: [
          { id: '123', name: 'Foo' }
        ],
        organizations: [
          {
            id: '456',
            name: 'ACME'
          }
        ]
      )
    end

    it 'is enumerable' do
      subject.any?.must_equal(true)
    end

    it 'creates person proxies' do
      person = subject.first
      person.name.must_equal 'Bob'
      expected_mems = [
        { group: 'ACME', area: 'Foo', start_date: '2010-06-01', end_date: '2015-05-22' }
      ]
      person.memberships.must_equal expected_mems
    end
  end
end
