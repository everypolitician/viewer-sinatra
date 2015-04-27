require_relative '../rakefile_common.rb'

@DEST = 'wales'

task :process_json => [:ensure_legislative_period, :default_memberships_to_current_term]
