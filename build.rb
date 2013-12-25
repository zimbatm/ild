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
