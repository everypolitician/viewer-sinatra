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
