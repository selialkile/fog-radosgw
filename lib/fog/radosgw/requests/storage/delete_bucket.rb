module Fog
  module Radosgw
    class Storage
      class Real
        include Utils

        def delete_bucket(bucket)
          path    = "admin/bucket"
          bucket = escape(bucket)
          query   = "?bucket=#{bucket}&purge-objects=true&format=json"
          params  = {
            :method => 'DELETE',
            :path => path,
          }

          begin
            response = Excon.delete("#{@scheme}://#{@host}/#{path}#{query}",
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