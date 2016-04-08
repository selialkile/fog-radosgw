module Fog
  module Radosgw
    class Provisioning
      class Real
        include Utils

        def create_new_key(user_id)
          if get_user(user_id).status == 404
            raise Fog::Radosgw::Provisioning::AlreadyExists, "User with user_id #{user_id} already exists."
          end

          path         = "admin/user"
          user_id      = escape(user_id)
          query        = "?key&uid=#{user_id}&format=json"
          params       = {
            :method => 'PUT',
            :path => path,
          }

          begin
            response = Excon.put("#{@scheme}://#{@host}/#{path}#{query}",
                                 :headers => signed_headers(params))
            if !response.body.empty?
              case response.headers['Content-Type']
              when 'application/json'
                response.body = Fog::JSON.decode(response.body)
              end
            end
            response
          rescue Excon::Errors::Conflict => e
            raise Fog::Radosgw::Provisioning::UserAlreadyExists.new
          rescue Excon::Errors::BadRequest => e
            raise Fog::Radosgw::Provisioning::ServiceUnavailable.new
          end
        end
      end

    end
  end
end