# frozen_string_literal: true
require 'test_helper'

describe 'PersonCard' do
  describe 'cabinet memberships' do
    before { stub_term_table('f88ce37', 'Estonia/Riigikogu') }
    let(:legislature) { index_at_known_sha.country('Estonia').legislature('Riigikogu') }
    let(:term) { legislature.term('13') }
    let(:cabinet_membership) { term.cabinet_memberships.first }
    let(:person) { legislature.popolo.persons.find_by(id: cabinet_membership.person_id) }
    subject { PersonCard.new(person: person, term: term) }

    it 'returns a list of cabinet memberships for a person' do
      subject.cabinet_memberships.must_include cabinet_membership
    end
  end
end
