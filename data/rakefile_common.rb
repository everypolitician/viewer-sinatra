require 'json'
require 'open-uri'
require 'rake/clean'

CLEAN.include('processed.json')

Numeric.class_eval { def empty?; false; end }

file 'popit.json' do 
  popit_src = @POPIT_URL || "https://#{@POPIT || @DEST}.popit.mysociety.org/api/v0.1/export.json"
  File.write('popit.json', open(popit_src).read) 
end

task :rebuild => [ :clean, 'processed.json' ]

task :default => 'processed.json'

task :install => 'processed.json' do
  FileUtils.cp('processed.json', "../#{@DEST}.json")
end

