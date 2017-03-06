# frozen_string_literal: true
require 'test_helper'

describe 'Everypolitician::LegislativePeriodExtension' do
  describe 'getting cabinet positions' do
    before do
      stub_everypolitician_data_request('f88ce37/data/Estonia/Riigikogu/unstable/positions.csv')
    end

    let(:legislature) { index_at_known_sha.country('Estonia').legislature('Riigikogu') }
    let(:term_12) { legislature.term('12') }
    let(:term_13) { legislature.term('13') }

    describe 'Taavi Rõivas' do
      let(:taavi_id) { '6b71eefc-413d-4db6-88f0-d7ff845ebaf1' }
      let(:term_12_memberships) { term_12.cabinet_memberships.select { |m| m.person_id == taavi_id } }
      let(:term_13_memberships) { term_13.cabinet_memberships.select { |m| m.person_id == taavi_id } }

      it 'has the correct number of cabinet positions for each term' do
        term_12_memberships.size.must_equal 2
        term_13_memberships.size.must_equal 1
      end

      it 'has the correct memberships information for term 12' do
        social_affairs, prime_minister = term_12_memberships

        social_affairs.label.must_equal 'Minister of Social Affairs'
        social_affairs.start_date.must_equal '2012-12-11'
        social_affairs.end_date.must_equal '2014-03-26'

        prime_minister.label.must_equal 'Prime Minister of Estonia'
        prime_minister.start_date.must_equal '2014-03-26'
        prime_minister.end_date.must_be_nil
      end

      it 'has the correct memberships information for term 13' do
        prime_minister = term_13_memberships.first

        prime_minister.label.must_equal 'Prime Minister of Estonia'
        prime_minister.start_date.must_equal '2014-03-26'
        prime_minister.end_date.must_be_nil
      end
    end
  end
end
