require 'docker/http'

module Docker
  module Containers
    include Docker::HTTP
    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#list-containers
    def list_containers(params={})
      allowed(params,
        :all,
        :before,
        :limit,
        :since,
        :size,
      )

      request(
        expects: 200,
        method: GET,
        path: "/containers/json",
        query: params,
      )
    end

    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#create-a-container
    def create_container(params={})
      allowed(params,
        :attach_stderr,
        :attach_stdin,
        :attach_stdout,
        :cmd,
        :dns,
        :env,
        :hostname,
        :image,
        :memory,
        :memory_swap,
        :open_stdin,
        :port_specs,
        :privileged,
        :stdin_once,
        :tty,
        :user,
        :volumes,
        :volumes_from,
        :working_dir,
      )

      post(
        method: POST,
        path: "/containers/create",
        body: JSON.dump(params),
        headers: {
          HEADER_CONTENT_TYPE => MIME_JSON,
        }
      )
    end

    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#inspect-a-container
    def container_inspect(params={})
      id = extract!(params, :id)

      request(
        expects: 200,
        method: GET,
        path: "/containers/#{id}/json",
      )
    end

    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#list-processes-running-inside-a-container
    def container_top(params={})
      id = extract!(params, :id)
      allowed(params, :ps_args)

      request(
        expects: 200,
        method: GET,
        path: "/containers/#{id}/top",
        query: params
      )
    end

    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#inspect-changes-on-a-container-s-filesystem
    def container_changes(params={})
      id = extract!(params, :id)

      request(
        expects: 200,
        method: GET,
        path: "/containers/#{id}/changes",
        query: params
      )
    end

    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#export-a-container
    def container_export(params={})
      id = extract!(params, :id)

      request(
        expects: 200,
        method: GET,
        path: "/containers/#{id}/export",
        query: params
      )
    end

    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#start-a-container
    def container_start(params={})
      id = extract!(params, :id)
      allowed(params,
        :binds,
        :lxc_conf
      )

      request(
        expects: 204,
        method: POST,
        path: "/containers/#{id}/start",
        body: JSON.dump(to_go(params)),
        headers: {
          CONTENT_TYPE => MIME_JSON,
        }
      )
    end

    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#stop-a-container
    def container_stop(params={})
      id = extract!(params, :id)
      allowed(params, :t)

      request(
        expects: 204,
        method: POST,
        path: "/containers/#{id}/stop",
        query: params,
      )
    end

    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#restart-a-container
    def container_restart(params={})
      id = extract!(params, :id)
      allowed(params, :t)

      request(
        expects: 204,
        method: POST,
        path: "/containers/#{id}/restart",
        query: params,
      )
    end

    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#kill-a-container
    def container_kill(params={})
      id = extract!(params, :id)

      request(
        expects: 204,
        method: POST,
        path: "/containers/#{id}/kill",
      )
    end

    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#attach-to-a-container
    #
    # TODO: handle stdin streaming
    # TODO: handle stdout streaming
    def container_attach(params={}, &streamer)
      raise ArgumentError unless block_given?
      id = extract!(params, :id)
      allowed(params,
        :logs,
        :stream,
        :stdin,
        :stdout,
        :stderr,
      )

      request(
        expects: 204,
        method: POST,
        path: "/containers/#{id}/kill",
        response_block: streamer
      )
    end

    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#wait-a-container
    def container_wait(params={})
      id = extract!(params, :id)

      request(
        expects: 200,
        method: POST,
        path: "/containers/#{id}/wait",
      )
    end

    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#remove-a-container
    def container_remove(params={})
      id = extract!(params, :id)
      allowed(params, :v)

      request(
        expects: 204,
        method: DELETE,
        path: "/containers/#{id}",
        query: params,
      )
    end

    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#copy-files-or-folders-from-a-container
    def container_copy(params={})
      id, resource = extract!(params, :id, :resource)

      request(
        expects: 200,
        method: POST,
        path: "/containers/#{id}/copy",
        body: JSON.dump(Resource: resource),
        headers: {
          CONTENT_TYPE => MIME_JSON
        }
      )
    end
  end
end
