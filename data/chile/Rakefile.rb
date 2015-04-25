require_relative '../rakefile_common.rb'

@POPIT = 'pmocl'
@DEST = 'chile'

# Must be done in correct order
task :default_memberships_to_current_term => :switch_party_to_behalf

task :process_json => [
  :clean_orphaned_memberships, 
  :ensure_legislative_period,
  :default_memberships_to_current_term
] 
