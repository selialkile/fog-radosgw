module Fog
  module Radosgw
    class Storage
      class Real
        include Utils

        def list_buckets(user_id)
          path    = "admin/bucket"
          user_id = escape(user_id)
          query   = "?uid=#{user_id}&stats=true&format=json"
          params  = {
            :method => 'GET',
            :path => path,
          }

          begin
            response = Excon.get("#{@scheme}://#{@host}/#{path}#{query}",
                                 :headers => signed_headers(params))
            if !response.body.empty?
              case response.headers['Content-Type']
              when 'application/json'
                response.body = Fog::JSON.decode(response.body)
              end
            end
            response
          rescue Excon::Errors::BadRequest => e
            raise Fog::Radosgw::Storage::ServiceUnavailable.new
          end

        end
      end

      class Mock
        def list_buckets
        end
      end
    end
  end
end