require 'minitest/autorun'

class Minitest::Spec
  def index_at_known_sha
    @index_at_known_sha ||= EveryPolitician::Index.new('d8a4682f')
  end
end
