require 'minitest/autorun'
require_relative '../../lib/page/home'

describe 'Homepage' do
  subject do
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
      Everypolitician.countries_json = cjson_src
      subject.world[:colombia][:totalPeople].must_equal 269
    end
  end

  describe 'total_people' do
    it 'should know the person count ' do
      Everypolitician.countries_json = cjson_src
      subject.total_people.must_equal 70_943
    end
  end

  describe 'total_statements' do
    it 'should know the statement count' do
      Everypolitician.countries_json = cjson_src
      subject.total_statements.must_equal 3_218_179
    end
  end
end
