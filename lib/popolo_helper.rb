# frozen_string_literal: true

module Popolo
  module Helper
    def term_table_url(term)
      '/%s/%s/term-table/%s.html' % [
        term.country.slug.downcase,
        term.legislature.slug.downcase,
        term.slug,
      ]
    end

    # http://stackoverflow.com/questions/1078347/is-there-a-rails-trick-to-adding-commas-to-large-numbers
    def commify(number)
      number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end

    def wikidata_link(object)
      return unless wdid = object.wikidata
      '<a href="https://www.wikidata.org/wiki/%s">%s</a>' % [wdid, wdid]
    end

    def number_to_millions(num)
      result = (num.to_f / 100_000).floor.to_f / 10
      result.modulo(1) < 0.1 ? result.to_i : result
    end
  end
end
