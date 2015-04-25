require_relative '../rakefile_common.rb'

@DEST = 'wales'

file 'processed.json' => 'popit.json' do
  json = JSON.load(File.read('popit.json'), lambda { |h| 
    if h.class == Hash 
      h.reject! { |_, v| v.nil? or v.empty? }
      h.reject! { |k, v| (k == 'url' or k == 'html_url') and v[/popit.mysociety.org/] }
    end
  })

  leg = json['organizations'].find { |h| h['classification'] == 'legislature' }
  unless leg.has_key?('legislative_periods') and not leg['legislative_periods'].count.zero? 
    leg['legislative_periods'] = [{
      id: 'term/current',
      name: 'current',
      classification: 'legislative period',
    }]

    json['memberships'].find_all { |m| m['organization_id'] == 'legislature' && m['role'] == 'member' }.each do |m|
      m['legislative_period_id'] ||= 'term/current'
    end
  end
  
  File.write('processed.json', JSON.pretty_generate(json))
end

