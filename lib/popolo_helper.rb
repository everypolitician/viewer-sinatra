module Popolo

  require 'date'
  require 'json'
  require 'promise'

  class Data

    def initialize(file)
      @_file = file
    end

    def json
      @_data ||= JSON.parse(File.read("data/#{@_file}.json"))
    end

    def persons
      json['persons']
    end

    def organizations
      json['organizations']
    end

    def memberships
      @_mems ||= json['memberships'].map { |m|
        m['organization'] ||= promise { party_from_id(m['organization_id']) }
        m['on_behalf_of'] ||= promise { party_from_id(m['on_behalf_of_id']) }
        m['person']       ||= promise { person_from_id(m['person_id']) or raise "No such person: #{m['person_id']}" }
        if m.has_key?('legislative_period_id')
          m['legislative_period'] ||= promise { term_from_id(m['legislative_period_id']) }
          m['start_date'] ||= promise { m['legislative_period']['start_date'] || '' }
          m['end_date'] ||= promise { m['legislative_period']['end_date'] || '' }
        end
        m
      }
    end

    def legislature
      # TODO cope with more than one!
      json['organizations'].find { |o| o['classification'] == 'legislature' }
    end

    def chambers
      json['organizations'].find_all { |o| o['classification'] == 'chamber' } 
    end

    def parties
      json['organizations'].find_all { |o| o['classification'] == 'party' }
    end

    def terms
      legislature['legislative_periods'] || legislature['terms'] 
    end

    def term_list
      terms.sort_by { |t| [ (t['start_date'] || '1001-01-01'), (t['end_date'] || '2999-12-31') ] }
    end

    def terms_with_members
      terms.reject { |t| term_memberships(t).count.zero? }
    end

    def current_term
      term_list.last 
    end


    def legislative_memberships
      memberships.find_all { |m| [legislature, chambers].flatten.map { |o| o['id'] }.include? m['organization_id'] }
    end

    def term_from_id(id)
      terms.detect { |t| t['id'] == id } || terms.detect { |t| t['id'].end_with? "/#{id}" }
    end

    def term_memberships(t)
      mems_with_terms = legislative_memberships.find_all { |m| m['legislative_period_id'] == t['id'] }
    end

    def person_from_id(id)
      persons.detect { |r| r['id'] == id } || persons.detect { |r| r['id'].end_with? "/#{id}" }
    end

    def people_with_name(name)
      persons.find_all { |p| p['name'] == name } 
    end

    def person_memberships(p)
      memberships.find_all { |m| m['person_id'] == p['id'] }
    end

    def person_legislative_memberships(p)
      legislative_memberships.find_all { |m| m['person_id'] == p['id'] }
    end

    def party_from_id(id)
      p = organizations.detect { |r| r['id'] == id } || organizations.detect { |r| r['id'].end_with? "/#{id}" }
    end

    def party_memberships(id)
      legislative_memberships.find_all { |m| m['on_behalf_of_id'] == id }
    end

    def named_area_memberships(name)
      legislative_memberships.find_all { |m| m.has_key?('area') && m['area']['name'] == name }
    end

  end

  module Helper

    def generate_url(type, obj)
      raise "#{type} is Nil" if obj.nil?
      raise "#{type} has no 'id': #{obj}" unless obj.has_key? 'id'
      [ '', @country, type, obj['id'].split('/').last ].join("/")
    end

    def person_url(p)
      generate_url('person', p)
    end

    def party_url(p)
      generate_url('party', p)
    end

    def term_url(t)
      generate_url('term', t)
    end

    def term_table_url(t)
      generate_url('term_table', t)
    end

    def area_name_url(t)
      # Ugh. We should probably change generate_url to take an
      # (optional) argument for which key to look up by
      generate_url('area', {'id' => t})
    end

  end
end

