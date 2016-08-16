require 'minitest/autorun'
require_relative '../../lib/world'

describe 'World' do
  subject { World.new }

  it 'should know other names for countries' do
    subject.as_json[:estonia][:allNames].must_include 'Estland'
  end
end
