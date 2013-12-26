require 'json'
require 'octokit'
require 'omniauth/strategies/github'
require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/namespace'
require 'sinatra/respond_with'

require 'docker'

module Ild
  class App < Sinatra::Base
    helpers Sinatra::ContentFor
    register Sinatra::Namespace
    register Sinatra::RespondWith

    configure do
      use Rack::Session::Cookie, secret: ENV['RACK_SECRET']
      use OmniAuth::Builder do
        provider(
          :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'],
          scope: "public_repo"
        )
      end

      set :root, File.dirname(__FILE__)
      set :views, proc{ File.join(root, "templates") }
    end

    respond_to :html, :json

    before do
      cache_control :public, :must_revalidate
    end

    [:get, :post].each do |method|
      public_send(method, '/auth/:provider/callback') do
        p env['omniauth.auth']
        {woot: true, provider: params[:provider]}
      end
    end

    get '/', provides: [:html, :json] do
      respond_with :index
    end

    namespace '/:user/:repo' do
      get do
        # returns a list of builds
      end

      get '/:git_ref' do
        # returns infos on a build
      end

      get '/:git_ref/logs' do
        # returns infos on a build
        content_type :text
        stream(:keep_open) do |out|
          while !out.closed? do
            sleep 1
            p [:sleep, Time.now, params[:job_id]]
            out << [Time.now.to_s, params[:job_id], "\n"].join
          end
        end
      end
    end

    post '/github_webhook' do
      p JSON.parse(params[:payload])
    end
  end
end
