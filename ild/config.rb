module Ild
  @github_token = ENV['GITHUB_TOKEN']
  @docker_host  = ENV['DOCKER_HOST']
  class << self
    attr_accessor :github_token
    attr_accessor :docker_host
  end
end
