module GoogleApps
  require 'google/api_client'

  class Client

    include ClassLogger

    class << self
      def client
        @client ||= Google::APIClient.new(options={:application_name => "CalCentral", :application_version => "v1", :auto_refresh_token => true, :retries => 3})
      end

      def discover_resource_method(api, resource, method)
        begin
          discover_api(api).send(resource.to_sym).send(method.to_sym)
        rescue => e
          logger.fatal "#{name}: #{e.to_s} - Unable to resolve resource method"
          nil
        end
      end

      def new_auth(credential_store, access_token_override = nil, options = {})
        storage = Google::APIClient::Storage.new credential_store
        auth = storage.authorize
        auth.access_token = access_token_override unless access_token_override.nil?
        if options && options['refresh_token'] && options['expiration_time']
          auth.refresh_token = options['refresh_token']
          auth.expires_in = 3600
          auth.issued_at = Time.at(options['expiration_time'] - 3600)
        end
        if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
          config = credential_store.load_credentials
          flow = Google::APIClient::InstalledAppFlow.new({
                                                           :client_id => config.client_id,
                                                           :client_secret => config.client_secret,
                                                           :scope => config.scope})
          auth = flow.authorize storage
        end
        auth
      end

      def generate_request_hash(page_params)
        request_hash = {
          :api_method => page_params[:resource_method]
        }
        request_hash[:parameters] = page_params[:params] unless page_params[:params].blank?
        request_hash[:body] = page_params[:body] unless page_params[:body].blank?
        request_hash[:headers] = page_params[:headers] unless page_params[:headers].blank?
        request_hash
      end

      def request_page(authorization, page_params)
        request_hash = generate_request_hash page_params
        client = GoogleApps::Client.client.dup
        client.authorization = authorization
        request = client.generate_request(options=request_hash)
        logger.debug "Google request is #{request.inspect}"
        client.execute(request)
      end

      private

      def discover_version(api)
        client.preferred_version(api).version
      end

      def discover_api(api)
        client.discovered_api(api, discover_version(api))
      end
    end

  end
end
