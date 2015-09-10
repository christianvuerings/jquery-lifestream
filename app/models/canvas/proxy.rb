module Canvas
  require 'signet/oauth_2/client'

  class Proxy < BaseProxy
    include ClassLogger, SafeJsonParser
    include Cache::UserCacheExpiry
    include Proxies::Mockable

    attr_accessor :client

    APP_ID = 'Canvas'
    APP_NAME = 'bCourses'

    def self.new(*args, &blk)
      # Initialize mocks only after subclass initialization has set instance variables needed for URL matching.
      proxy = super
      proxy.initialize_mocks if proxy.fake
      proxy
    end

    def self.access_granted?(user_id)
      user_id && has_account?(user_id)
    end

    def self.default_response(options={})
      # Overrides the default response in ResponseWrapper so as not to include a :body element on errors.
      {error: options[:user_message_on_exception], statusCode: 503}
    end

    def self.has_account?(user_id)
      Settings.canvas_proxy.fake || (Canvas::SisUserProfile.new(user_id: user_id).get.present?)
    end

    def initialize(options = {})
      super(Settings.canvas_proxy, options)
      if @fake
        @uid = @settings.test_user_id
        access_token = 'fake_access_token'
      else
        access_token = options[:access_token] || @settings.admin_access_token
      end
      @client = Signet::OAuth2::Client.new(:access_token => access_token)
      @url_root = options[:url_root] || @settings.url_root
    end

    def wrapped_get(api_path, opts={}, &block)
      wrapped_request(api_path, opts.merge(method: :get), &block)
    end

    def wrapped_post(api_path, params = {}, &block)
      wrapped_request(api_path, {method: :post, body: params}, &block)
    end

    def wrapped_put(api_path, params = {}, &block)
      wrapped_request(api_path, {method: :put, body: params}, &block)
    end

    def wrapped_delete(api_path, params = {}, &block)
      wrapped_request(api_path, {method: :delete, body: params}, &block)
    end

    def paged_get(api_path, opts={})
      map_pages = opts.delete :map_pages
      params = opts.reverse_merge(per_page: 100).to_query
      results = []
      response = safe_request do
        while params do
          response = request_internal "#{api_path}?#{params}"
          initial_status_code ||= response.status
          break unless response.status == 200 && (page_results = safe_json response.body)
          if map_pages
            results.concat map_pages.call(page_results)
          else
            results.concat page_results
          end
          yield response if block_given?
          params = next_page_params(response)
        end
        {statusCode: initial_status_code}
      end
      response.merge(body: results)
    end

    def wrapped_request(api_path, opts)
      safe_request do
        response = request_internal(api_path, opts)
        {
          statusCode: response.status,
          body: safe_json(response.body)
        }
      end
    end

    def raw_request(api_path, fetch_options = {})
      safe_request do
        response = request_internal(api_path, fetch_options)
        {
          statusCode: response.status,
          body: response.body
        }
      end
    end

    def safe_request
      yield
    rescue => e
      self.class.handle_exception(
        e, self.class.cache_key(@uid),
        {id: @uid, user_message_on_exception: 'Remote server unreachable'}
      )
    end

    def request_internal(api_path, fetch_options = {})
      fetch_options.reverse_merge!(
        :method => :get,
        :uri => "#{api_root}/#{api_path}"
      )
      logger.info "Making request with @fake = #{@fake}, options = #{fetch_options}, cache expiration #{self.class.expires_in}"
      response = ActiveSupport::Notifications.instrument('proxy', {url: fetch_options[:uri], class: self.class}) do
        if (nonstandard_connection = fetch_options[:non_oauth_connection])
          nonstandard_connection.get(fetch_options[:uri])
        else
          @client.fetch_protected_resource(fetch_options)
        end
      end
      if response.status == 404
        if existence_check
          logger.debug "404 status returned for URL '#{fetch_options[:uri]}', UID #{@uid}"
        else
          error_object = (parsed = safe_json response.body) && parsed['errors']
          raise Errors::ProxyError.new(
            'Connection failed', response: response, url: fetch_options[:uri], uid: @uid,
            return_feed: {statusCode: 404, error: error_object}
          )
        end
      elsif response.status >= 400
        raise Errors::ProxyError.new('Connection failed', response: response, url: fetch_options[:uri], uid: @uid)
      end
      response
    end

    def optional_cache(public_options, private_options)
      cache = public_options.has_key?(:cache) ? public_options[:cache] : private_options[:default]
      if cache
        self.class.fetch_from_cache(private_options[:key]) { yield }
      else
        yield
      end
    end

    def api_root
      "#{@url_root}/api/v1"
    end

    def existence_check
      false
    end

    private

    def mock_request
      super.merge(uri_matching: "#{api_root}/#{request_path}")
    end

    def next_page_params(response)
      # If the response's link header included a "next" page pointer...
      if response && (next_link = LinkHeader.parse(response['link']).find_link(['rel', 'next']))
        # ... then extract the query string from its URL.
        /.+\?(.+)/.match(next_link.href)[1]
      else
        nil
      end
    end

    def request_path
      ''
    end
  end
end
