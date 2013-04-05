require 'google/api_client'

class GoogleProxyClient
  class << self
    def client
      @client ||= Google::APIClient.new(options={:application_name => "CalCentral", :application_version => "v1", :auto_refresh_token => true})
    end

    def discover_resource_method(api, resource, method)
      begin
        discover_api(api).send(resource.to_sym).send(method.to_sym)
      rescue Exception => e
        Rails.logger.fatal "#{name}: #{e.to_s} - Unable to resolve resource method"
        nil
      end
    end

    def new_fake_auth
      new_auth("fake_access_token")
    end

    def new_client_auth(token_hash)
      new_auth(token_hash["access_token"], token_hash)
    end

    def request_page(authorization, page_params)
      request_hash = {
        :api_method => page_params[:resource_method]
      }
      request_hash[:parameters] = page_params[:params] unless page_params[:params].blank?
      request_hash[:body] = page_params[:body] unless page_params[:body].blank?
      request_hash[:headers] = page_params[:headers] unless page_params[:headers].blank?
      request_hash[:authorization] = @authorization

      client = GoogleProxyClient.client.dup
      request = client.generate_request(options=request_hash)
      client.authorization = authorization

      Rails.logger.debug "Google request is #{request.inspect}"
      client.execute(request)
    end

    private

    def new_auth(access_token, options={})
      authorization = client.authorization.dup
      authorization.client_id = Settings.google_proxy.client_id
      authorization.client_secret = Settings.google_proxy.client_secret
      authorization.access_token = access_token
      ## Not setting these in explicit fake mode will prevent the api_client from attempting to refresh tokens.
      if options && options["refresh_token"] && options["expiration_time"]
        authorization.refresh_token = options["refresh_token"]
        authorization.expires_in = 3600
        authorization.issued_at = Time.at(options["expiration_time"] - 3600)
      end
      authorization
    end

    def discover_version(api)
      client.preferred_version(api).version
    end

    def discover_api(api)
      client.discovered_api(api, discover_version(api))
    end
  end

end