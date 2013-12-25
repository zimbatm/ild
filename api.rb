require 'grape'
require 'octokit'
require 'omniauth/strategies/github'

class API < Grape::API
  use OmniAuth::Builder do
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
  end

  format :json

  get do
    {hello: 'world'}
  end
end
