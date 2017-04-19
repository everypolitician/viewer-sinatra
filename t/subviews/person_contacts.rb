# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/subviews/person_contacts'
require 'everypolitician'

describe 'Social Subview' do
  subject do
    PersonContacts.new(person: index_at_known_sha.country('uk').legislature('commons')
    .popolo
    .persons
    .select { |p| p.name == 'David Anderson' }.first)
  end

  it 'should list an email address' do
    email = { label: 'Email', value: 'andersonda@parliament.uk' }
    subject.entries.must_include email
  end

  it 'should list a phone number' do
    phone = { label: 'Phone', value: '020 7219 4348' }
    subject.entries.must_include phone
  end

  it 'should list a fax number' do
    fax = { label: 'Fax', value: '020 7219 8276' }
    subject.entries.must_include fax
  end
end

describe 'multiple entries' do
  subject do
    PersonContacts.new(person: index_at_known_sha.country('bulgaria').legislature('national-assembly')
    .popolo
    .persons
    .select { |p| p.name == 'ВЕНЦИСЛАВ АСЕНОВ ЛАКОВ' }.first)
  end

  it 'should list multiple email addresses' do
    email_one = { label: 'Email', value: 'vencilakov@abv.bg' }
    email_two = { label: 'Email', value: 'ventsislav.lakov@parliament.bg' }
    subject.entries.must_include email_one
    subject.entries.must_include email_two
  end
end
