require 'grape'
require 'json'
require 'octokit'
require 'omniauth/strategies/github'

class API < Grape::API
  format :json

  get do
    {hello: 'world'}
  end

  get '/auth/:provider/callback' do
    p env['omniauth.auth']
    p 'GET'
    {woot: true, provider: params[:provider]}
  end

  post '/auth/:provider/callback' do
    p env['omniauth.auth']
    p 'POST'
    {woot: true, provider: params[:provider]}
  end

  post '/github_webhook' do
    p JSON.parse(params[:payload])
  end
end

App = Rack::Builder.new do
  use Rack::Session::Cookie, secret: ENV['RACK_SECRET']
  use OmniAuth::Builder do
    provider(
      :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'],
      scope: "public_repo"
    )
  end
  run API
end
