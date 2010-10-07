require 'httparty'
require 'copycopter_client/version'
require 'copycopter_client/configuration'
require 'copycopter_client/client'
require 'copycopter_client/helper'

# Plugin for applications to store their copy in a remote service to be editable by clients
module CopycopterClient
  LOG_PREFIX = "** [Copycopter] "

  # HTTP_ERRORS = [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError]

  class << self
    # def remote_lookup_disabled?
    #   Thread.current[:disabled] && Thread.current[:disabled] >= Time.now
    # end

    # def disable_remote_lookup
    #   Thread.current[:disabled] = Time.now + (5 * 60)
    # end

    # def enable_remote_lookup
    #   Thread.current[:disabled] = nil
    # end

    # def copy_for(key, default = nil)
    #   return default if remote_lookup_disabled?
    #   if !configuration.test?
    #     result = fetch(key, default)

    #     if result && result['blurb']
    #       "#{result['blurb']['content']} #{edit_link(result['blurb']) if !configuration.public?}"
    #     else
    #       result
    #     end
    #   else
    #     default
    #   end
    # rescue *HTTP_ERRORS
    #   disable_remote_lookup
    #   default
    # end
    # alias_method :s, :copy_for

    # private

    # def fetch(key, default = nil)
    #   perform_caching(key) do
    #     options  = { :key => key, :environment => configuration[:environment_name] }
    #     response = CopycopterClient.client.get(options)

    #     if response.code != 200
    #       CopycopterClient.client.create(options.merge(:content => default))
    #       default
    #     else
    #       if response['blurb']
    #         response
    #       else
    #         response.body
    #       end
    #     end
    #   end
    # end

    # def edit_link(blurb)
    #   "<a target='_blank' href='#{url}/projects/#{blurb["project_id"]}/blurbs/#{blurb['id']}/edit'>Edit</a>"
    # end

    # def url
    #   URI.parse("#{configuration[:protocol]}://#{configuration[:host]}:#{configuration[:port]}")
    # end

  end

end
