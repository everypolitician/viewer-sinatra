# frozen_string_literal: true
require 'test_helper'
require_relative '../../lib/everypolitician_extensions.rb'

describe 'MembershipExtensions' do
  subject do
    stub_popolo('3df153b', 'Austria/Nationalrat')
    index_at_known_sha.country('austria')
                      .legislature('nationalrat')
                      .popolo
                      .memberships
                      .first
  end

  it 'should return an organization with the expected id' do
    subject.group.id.must_equal 'party/spÖ'
  end

  it 'should return an Organization object' do
    subject.group.class.must_equal Everypolitician::Popolo::Organization
  end

  it 'should return an area with the expected id' do
    subject.area.id.must_equal 'area/wahlkreis:_6d_–_obersteiermark'
  end

  it 'should return an Area object' do
    subject.area.class.must_equal Everypolitician::Popolo::Area
  end
end

describe 'MembershipExtensions -- memberships with no known groups or area names' do
  subject do
    stub_popolo('2b38667', 'Afghanistan/Wolesi_Jirga')
    index_at_known_sha.country('afghanistan')
                      .legislature('wolesi-jirga')
                      .popolo
                      .memberships
                      .first
  end

  it 'should return nil if a membership has no group data' do
    subject.area.must_be_nil
  end

  it 'should return "unkown" if membership’s area name is unknown' do
    subject.group.name.must_equal 'unknown'
  end
end
