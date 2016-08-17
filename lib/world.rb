require 'json'

class World
  def initialize(file = 'world.json')
    @file = file
  end

  def as_json
    @_wjson ||= JSON.parse(File.read(file), symbolize_names: true)
  end

  private

  attr_reader :file
end
