module Cal1card
  class MyCal1card < UserSpecificModel
    include Cache::LiveUpdatesEnabled
    include Cache::FeedExceptionsHandled
    include Proxies::MockableXml
    include HttpRequester

    def initialize(uid, options={})
      super(uid, options)
      @settings = Settings.cal1card_proxy
      @fake = (options[:fake] != nil) ? options[:fake] : @settings.fake
      initialize_mocks if @fake
    end

    def default_message_on_exception
      'An error occurred retrieving data for Cal 1 Card. Please try again later.'
    end

    def get_feed_internal
      if Settings.features.cal1card
        get_converted_xml
      else
        {}
      end
    end

    def get_converted_xml
      url = "#{@settings.base_url}?uid=#{@uid}"
      logger.info "Internal_get: Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
      response = get_response(
        url,
        basic_auth: {username: @settings.username, password: @settings.password}
      )
      feed = response.parsed_response
      logger.debug "Cal1Card remote response: #{response.inspect}"

      camelized = HashConverter.camelize feed
      camelized[:cal1card].merge({
        statusCode: 200
      })
    end

    def mock_xml
      read_file('fixtures', 'xml', 'cal1card_feed.xml')
    end

  end
end

