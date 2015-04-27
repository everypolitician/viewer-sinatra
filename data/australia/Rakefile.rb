require 'csv'
require 'csv_to_popolo'

require_relative '../rakefile_common.rb'

@DEST = 'australia'
@JSON_FILE = 'fromcsv.json'

file 'popit.csv' => 'popit.json' do
  data = JSON.load(File.read('popit.json'))['persons'].map do |p|
    { 
      id: p['ids'].find { |i| i['provider'] == 'aph_id' }['id'],
      name: p['name'],
      party: p['data']['party'][0],
      house: p['data']['house'][0],
      source: (p['links'].find { |l| l['note'] == 'aph_profile_page' } || {})['url'],
      website: (p['links'].find { |l| l['note'] == 'website' } || {})['url'],
      photo: (p['links'].find { |l| l['note'] == 'aph_profile_photo' } || {})['url'],
      email: (p['contact_details'].find { |l| l['type'] == 'email' } || {})['value'],
      facebook: (p['contact_details'].find { |l| l['type'] == 'facebook' } || {})['value'],
      twitter: (p['contact_details'].find { |l| l['type'] == 'twitter' } || {})['value'],
    }
  end
  csv = data.first.keys.to_csv  + data.map { |r| r.values.to_csv }.join
  File.write('popit.csv', csv.gsub(',null',','))
end
CLEAN.include('popit.csv')

file 'fromcsv.json' => 'popit.csv' do
  data = Popolo::CSV.new('popit.csv').data
  json = JSON.pretty_generate(data)
  File.write('fromcsv.json', json)
end
CLEAN.include('fromcsv.json')

task :load_json => 'fromcsv.json'


task :connect_chambers => :ensure_legislature_exists do
  @json[:organizations].find_all { |h| h[:classification] == 'chamber' }.each do |c|
    c['parent_id'] ||= 'legislature'
  end
end

task :add_legislative_period => :ensure_legislature_exists do
  # Don't use the default one, because we have info
  # http://en.wikipedia.org/wiki/Chronology_of_Australian_federal_parliaments
  # Let's simply deal with Parliaments, ignoring the 6-year Senate

  leg = @json[:organizations].find { |h| h[:classification] == 'legislature' } or raise "No legislature"
  unless leg.has_key?(:legislative_periods) and not leg[:legislative_periods].count.zero? 
    leg[:legislative_periods] = [{
      id: 'term/44',
      name: '44th Parliament',
      start_date: '2013-09-07',
      classification: 'legislative period',
    }]
  end
end

task :process_json => [
  :load_json, 
  :connect_chambers,
  :add_legislative_period,
  :default_memberships_to_current_term,
] 

