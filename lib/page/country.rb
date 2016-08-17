require 'everypolitician'

module Page
  class Country
    def initialize(slug, ref = 'master')
      @slug = slug
      @ref  = ref
    end

    def country
      @country ||= EveryPolitician::Index.new(ref).country(slug)
    end

    def title
      "EveryPolitician: #{country.name}" if country
    end

    private

    attr_reader :slug, :ref
  end
end
