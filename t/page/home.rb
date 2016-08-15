require 'minitest/autorun'
require_relative '../../lib/page/home'

CJSON = 'https://cdn.rawgit.com/everypolitician/everypolitician-data/%s/countries.json'.freeze
SHA   = 'd8a4682f'.freeze

describe 'Homepage' do
  subject do
    # TODO: encapsulate + record this
    Everypolitician.countries_json = CJSON % SHA
    Page::Home.new
  end

  describe 'countries' do
    it 'should include Colombian Senate' do
      co = subject.countries.find { |c| c.name == 'Colombia' }
      co.legislatures.map(&:name).must_include 'Senado'
    end
  end

  describe 'world' do
    it 'should sum people in Colombia' do
      subject.world[:colombia][:totalPeople].must_equal 269
    end
  end

  describe 'total_people' do
    it 'should know the person count ' do
      subject.total_people.must_equal 70_943
    end
  end

  describe 'total_statements' do
    it 'should know the statement count' do
      subject.total_statements.must_equal 3_218_179
    end
  end
end
