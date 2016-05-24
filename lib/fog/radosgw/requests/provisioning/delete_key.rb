module Fog
  module Radosgw
    class Provisioning
      class Real
        include Utils

        def delete_key(access_key)
          path         = "admin/user"
          key          = escape(access_key)
          query        = "?key&access-key=#{key}&format=json"
          params       = {
            :method => 'DELETE',
            :path => path,
          }

          begin
            response = Excon.delete("#{@scheme}://#{@host}/#{path}#{query}", :headers => signed_headers(params))
            parse_response(response) unless response.body.empty?
            response
          rescue Excon::Errors::NotFound => e
            raise Fog::Radosgw::Provisioning::KeyNotFound.new
          rescue Excon::Errors::BadRequest => e
            raise Fog::Radosgw::Provisioning::ServiceUnavailable.new
          end
        end

        private

        def parse_response(response)
          response.body = Fog::JSON.decode(response.body) if application_json?(response)
        end

        def application_json?(response)
          response.headers['Content-Type'] == 'application/json'
        end
      end
    end
  end
end
