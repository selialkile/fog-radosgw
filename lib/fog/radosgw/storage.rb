module Fog
  module Radosgw
    class Storage < Fog::Service
      class ServiceUnavailable < Fog::Radosgw::Storage::Error; end

      requires :radosgw_access_key_id, :radosgw_secret_access_key
      recognizes :host, :path, :port, :scheme, :persistent, :path_style

      request_path 'fog/radosgw/requests/storage'
      request :list_buckets

      class Real
        include Utils

        def initialize(options = {})
          configure_uri_options(options)
          @radosgw_access_key_id     = options[:radosgw_access_key_id]
          @radosgw_secret_access_key = options[:radosgw_secret_access_key]
          @connection_options       = options[:connection_options] || {}
          @persistent               = options[:persistent]         || false
          @path_style               = options[:path_style]         || false

          @connection = Fog::XML::Connection.new(radosgw_uri, @persistent, @connection_options)
        end

        def request(params, parse_response = true, &block)
          begin
            response = @connection.request(params.merge({
              :host     => @host,
              :path     => "#{@path}/#{params[:path]}",
            }), &block)
          rescue Excon::Errors::HTTPStatusError => error
            if match = error.message.match(/<Code>(.*?)<\/Code>(?:.*<Message>(.*?)<\/Message>)?/m)
              case match[1]
              when 'ServiceUnavailable'
                raise Fog::Radosgw::Provisioning.const_get(match[1]).new
              else
                raise error
              end
            else
              raise error
            end
          end
          if !response.body.empty? && parse_response
            response.body = Fog::JSON.decode(response.body)
          end
          response
        end

      end

      class Mock
      end

    end
  end
end