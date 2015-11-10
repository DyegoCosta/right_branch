require_relative '../lib/right_branch'

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = 'random'
end
