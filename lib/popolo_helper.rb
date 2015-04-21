module Popolo

  require 'date'
  require 'json'

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
      json['memberships']
    end

    def legislature
      # TODO cope with more than one!
      json['organizations'].find { |o| o['classification'] == 'legislature' }
    end

    def parties
      json['organizations'].find_all { |o| o['classification'] == 'party' }
    end

    def terms
      legislature['terms']
    end

    def legislative_memberships
      # TODO expand!
      memberships.find_all { |m| m['organization_id'] == 'legislature' }
    end


    def term_from_id(id)
      terms.detect { |t| t['id'] == id } || terms.detect { |t| t['id'].end_with? "/#{id}" }
    end

    def term_memberships(t)
      # for now, solely by overlapping dates
      # TODO: direct memberships
      legislative_memberships.find_all { |m| 
        ( m['start_date'] <= (t['end_date'] || Date.today.to_s) and t['start_date'] <= (m['end_date'] || Date.today.to_s) )
      }.map { |m|
        m['person'] ||= person_from_id(m['person_id'])
        m
      }
    end

    def person_from_id(id)
      persons.detect { |r| r['id'] == id } || persons.detect { |r| r['id'].end_with? "/#{id}" }
    end

    def person_memberships(p)
      memberships.find_all { |m| m['person_id'] == p['id'] }.map { |m|
        m['organization'] ||= party_from_id(m['organization_id'])
        m['on_behalf_of'] ||= party_from_id(m['on_behalf_of_id'])
        m
      }
    end

    def party_from_id(id)
      p = organizations.detect { |r| r['id'] == id } || organizations.detect { |r| r['id'].end_with? "/#{id}" }
    end

    def party_memberships(id)
      legislative_memberships.find_all { |m| m['on_behalf_of_id'] == id }.map { |m|
        m['person'] ||= person_from_id(m['person_id'])
        m
      }
    end

    def named_area_memberships(name)
      legislative_memberships.find_all { |m| m.has_key?('area') && m['area']['name'] == name }.map { |m|
        m['person'] ||= person_from_id(m['person_id'])
        m
      }
    end

  end

  module Helper

    def generate_url(type, obj)
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

    def area_name_url(t)
      # Ugh. We should probably change generate_url to take an
      # (optional) argument for which key to look up by
      generate_url('area', {'id' => t})
    end

  end
end

