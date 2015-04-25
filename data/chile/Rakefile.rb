require_relative '../rakefile_common.rb'

@POPIT = 'pmocl'
@DEST = 'chile'

file 'processed.json' => 'popit.json' do
  json = JSON.load(File.read('popit.json'), lambda { |h| 
    if h.class == Hash 
      h.reject! { |_, v| v.nil? or v.empty? }
      h.reject! { |k, v| (k == 'url' or k == 'html_url') and v[/popit.mysociety.org/] }
    end
  }, { symbolize_names: true })

  # ensure no unmatched Memberships
  json[:memberships].keep_if { |m|
    json[:organizations].find { |o| o[:id] == m[:organization_id] } and
    json[:persons].find { |p| p[:id] == m[:person_id] } 
  }

  # ensure there's a legislative Organization
  if json[:organizations].find_all { |h| h[:classification] == 'legislature' }.count.zero?
    json[:organizations] << {
      classification: "legislature",
      name: "Legislature",
      id: "legislature",
    }
  end

  # ensure at least one legislative period
  leg = json[:organizations].find { |h| h[:classification] == 'legislature' } or raise "No legislature"
  unless leg.has_key?(:legislative_periods) and not leg[:legislative_periods].count.zero? 
    leg[:legislative_periods] = [{
      id: 'term/current',
      name: 'current',
      classification: 'legislative period',
    }]
  end

  # change Party Memberships to on_behalf_of
  # Here *all* other Orgs are Parties
  json[:organizations].find_all { |h| h[:classification] != 'legislature' }.each do |o|
    json[:memberships].find_all { |m| m[:organization_id] == o[:id] }.each do |m|
      m[:role] = 'member'
      m[:on_behalf_of_id] = o[:id]
      m[:organization_id] = 'legislature'
    end
  end

  # Set all Legislative memberships with no term to be current
  json[:memberships].find_all { |m| m[:organization_id] == 'legislature' && m[:role] == 'member' }.each do |m|
    m[:legislative_period_id] ||= 'term/current'
  end

  File.write('processed.json', JSON.pretty_generate(json))
end
