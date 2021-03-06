module Fog
  module Radosgw
    class Usage
      module Utils

        def sanitize_and_convert_time(time)
          fmt = '%Y-%m-%d %H:%M:%S'
          escape(time.strftime(fmt))
        end

      end

      class Real
        include Utils

        def get_usage(id, options = {})
          path        = "admin/usage"
          t_now       = Fog::Time.now
          start_time  = sanitize_and_convert_time(options[:start_time] || t_now - 86400)
          end_time    = sanitize_and_convert_time(options[:end_time]   || t_now)
          param_id    = id.nil? ? '' : "&uid=#{escape(id)}"
          query       = "?format=json&start=#{start_time}&end=#{end_time}#{param_id}"
          params      = {
            :method => 'GET',
            :path   => path,
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
            raise Fog::Radosgw::Provisioning::ServiceUnavailable.new
          end
        end
      end

      class Mock
        include Utils

        def get_usage(id, options = {})
          Excon::Response.new.tap do |response|
            response.status = 200
            response.headers['Content-Type'] = 'application/json'
            response.body = {
              'entries' =>  [],
              'summary'  => []
            }
          end
        end
      end
    end
  end
end
