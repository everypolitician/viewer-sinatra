# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/subviews/person_identifiers'
require 'everypolitician'

describe 'Identifiers Subview' do
  subject do
    PersonIdentifiers.new(person: index_at_known_sha.country('uk').legislature('commons')
    .popolo
    .persons
    .select { |p| p.name == 'Sarah Champion' }.first, identifiers: %w(datadotparl parliamentdotuk))
  end

  it 'should provide provide a list of identifiers with schemes specified in the identifiers argument' do
    datadotparl = { label: 'datadotparl', value: '4267' }
    dods = { label: 'dods', value: '101347' }
    parliamentdotuk = { label: 'parliamentdotuk', value: 'commons/sarah-champion/4267' }

    subject.entries.wont_include dods
    subject.entries.must_include parliamentdotuk
    subject.entries.must_include datadotparl
  end
end
