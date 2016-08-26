# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/subviews/person_bio'
require 'everypolitician'

describe 'Bio Subview: gender, birth and death date' do
  subject do
    PersonBio.new(person: index_at_known_sha.country('uk').legislature('commons')
    .popolo
    .persons
    .select { |p| p.name == 'Harry Harpham' }.first)
  end

  it 'should list the birth date of a member' do
    born = { label: 'Born', value: '1954-02-21' }
    subject.entries.must_include born
  end

  it 'should list the death date of a member' do
    died = { label: 'Died', value: '2016-02-04' }
    subject.entries.must_include died
  end

  it 'should list the gender of a member' do
    gender = { label: 'Gender', value: 'male' }
    subject.entries.must_include gender
  end

  it 'should not contain a nil value' do
    suffix = { label: 'Suffix', value: nil }
    subject.entries.wont_include suffix
  end
end

describe 'Bio Subview: honorific suffix' do
  subject do
    PersonBio.new(person: index_at_known_sha.country('uk').legislature('commons')
    .popolo
    .persons
    .select { |p| p.name == 'Dominic Grieve' }.first)
  end

  it 'should list the honorific suffix of a member' do
    suffix = { label: 'Suffix', value: 'Queen\'s Counsel' }
    subject.entries.must_include suffix
  end
end

describe 'Bio Subview: honorific prefix' do
  subject do
    PersonBio.new(person: index_at_known_sha.country('uk').legislature('commons')
    .popolo
    .persons
    .select { |p| p.name == 'Margaret Beckett' }.first)
  end

  it 'should list the honorific prefix of a member' do
    prefix = { label: 'Prefix', value: 'The Right Honourable' }
    subject.entries.must_include prefix
  end
end
