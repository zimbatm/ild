require 'excon'
require 'ostruct'
require 'json'
require 'addressable/uri'

require 'docker/containers'
require 'docker/http'

# Docker client against the v1.8 of the API
#
# Copies a lof of the design from the brillang heroku-api gem.
#
# http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/
module Docker
  include Docker::HTTP
  MIME_JSON = 'application/json'.freeze

  OPTIONS = {
    headers: {},
    nonblock: false,
  }

  HEADERS = {
    'Accept' => MIME_JSON
  }

  class Error < StandardError
  end

  class ErrorWithResponse < Error
    attr_reader :response

    def initialize(message, response)
      super message
      @response = response
    end
  end

  class UnknownError < ErrorWithResponse
  end

  class BadParameters < ErrorWithResponse
  end

  class ServerError < ErrorWithResponse
  end

  class Conflict < ErrorWithResponse
  end

  class ImpossibleToAttach < ErrorWithResponse
  end

  class FileNotFound < ErrorWithResponse
  end

  module ResponseEmbed
    def self.wrap(obj, response)
      obj.instance_variable_set :@response, response
      obj.extend(ResponseEmbed)
    end
    attr_reader :response
  end

  class Client
    attr_reader :addr

    include Containers
    
    def initialize(addr = 'tcp://:4243', options={})
      @addr = addr

      options = OPTIONS.merge(options)
      options[:headers] = HEADERS.merge(options[:headers])

      %w[host path port query scheme socket].each do |x|
        options.delete(x.to_sym)
      end

      uri = Addressable::URI.parse(addr)
      case uri.scheme
      when 'tcp', 'http'
        uri = Addressable::URI.new(
          scheme: 'http',
          host: uri.host.empty? ? 'localhost' : uri.host,
          port: uri.port,
        )
        origin = uri.origin
      when 'unix'
        options[:socket] = uri.path
        origin = 'unix:///'
      else
        raise ArgumentError, "unknown scheme '#{uri.scheme}'"
      end

      @connection = Excon.new(origin, options)
    end

    protected

    def to_ruby(obj)
      case obj
      when Array
        obj.map do |elem|
          to_ruby(elem)
        end
      when Hash
        obj.inject(OpenStruct.new) do |o, (k, v)|
          o[go2ruby k] = to_ruby(v)
          o
        end
      else
        obj
      end
    end

    def to_go(obj)
      obj.inject({}) do |h, (k, v)|
        h[ruby2go k] = v
        h
      end
    end

    def go2ruby(str)
      str.to_s.
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      downcase
    end

    def ruby2go(str)
      str.to_s.
      gsub(/\/(.?)/) { "::#{$1.upcase}" }.
      gsub(/(?:^|_)(.)/) { $1.upcase }
    end

    def allowed(params, *list)
      rejected = (params.keys - list)
      if rejected.any?
        raise ArgumentError, "params not allowed: #{rejected}"
      end
    end

    def extract!(params, *list)
      missing = (list - params.keys)
      if missing.any?
        raise ArgumentError, "params missing: #{missing}"
      end
      ret = params.values_at(list)
      list.each{|x| params.delete(x)}
      ret
    end

    def request(params, &block)
      response = @connection.request(params, &block)
      if response.headers[CONTENT_TYPE] == MIME_JSON
        body = JSON.parse(response.body)
        ret = to_ruby(body)
        ResponseEmbed.wrap(ret, response)
        return ret
      end
      response
    rescue Excon::Errors::HTTPStatusError => error
      klass = case error.response.status
        when 400 then BadParameters
        when 404 then FileNotFound
        when 406 then ImpossibleToAttach
        when 409 then Conflict
        when 500 then ServerError
        else UnknownError
      end

      reerror = klass.new(error.message, error.response)
      reerror.set_backtrace(error.backtrace)
      raise(reerror)
    ensure
      @connection.reset
    end

    def escape(string)
      CGI.escape(string).gsub('.', '%2E')
    end

  end
end
