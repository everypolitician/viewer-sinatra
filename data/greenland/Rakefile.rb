require_relative '../rakefile_common.rb'

@POPIT = 'inatsisartut'
@DEST = 'greenland'

file 'processed.json' => 'popit.json' do
  json = JSON.load(File.read('popit.json'), lambda { |h| 
    if h.class == Hash and h.has_key? 'legislative_periods'
      terms = h['legislative_periods'].sort_by { |p| p['name'] }
      terms.each_with_index do |p, i|
        p['start_date'] = p['name']
        p['name'] = "Inatsisartut #{i+1}"
        unless (i+1 == terms.size)
          p['end_date'] = Date.parse(terms[i+1]['name']) - 1
        end
      end
    end

    if h.class == Hash 
      h.reject! { |_, v| v.nil? or v.empty? }
      h.reject! { |k, v| (k == 'url' or k == 'html_url') and v[/popit.mysociety.org/] }
    end
  })
  File.write('processed.json', JSON.pretty_generate(json))
end


