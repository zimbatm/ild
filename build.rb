require File.expand_path('../boot', __FILE__)

require 'octokit'

Octokit.configure do |c|
  c.access_token = ENV['GITHUB_TOKEN']
  # c.login = ENV['GITHUB_USER']
  # c.password = ENV['GITHUB_PASS']
end

require 'irb'
require 'irb/completion'
IRB.start

# Octokit.create_status 'zimbatm/ild', '75d0d5c999ed6a62d5bda57f1370c92a55c04a93', 'success', target_url: 'https://ild.ngrok.com/foo/bar/baz', description: 'testing <b>the</b> damn thing'
#
# Octokit.statuses 'zimbatm/ild', 'master'
