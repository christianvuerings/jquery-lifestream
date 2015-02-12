module Cal1card
  class MyCal1card < UserSpecificModel
    include Cache::LiveUpdatesEnabled
    include Cache::FeedExceptionsHandled
    include HttpRequester

    def initialize(uid, options={})
      super(uid, options)
      @settings = Settings.cal1card_proxy
      @fake = (options[:fake] != nil) ? options[:fake] : @settings.fake
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
      if @fake
        logger.info "Fake = #@fake, getting data from XML fixture file; user #{@uid}; cache expiration #{self.class.expires_in}"
        feed = MultiXml.parse File.read(Rails.root.join('fixtures', 'xml', 'cal1card_feed.xml').to_s)
      else
        url = "#{@settings.feed_url}?uid=#{@uid}"
        logger.info "Internal_get: Fake = #@fake; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
        response = get_response(
          url,
          basic_auth: {username: @settings.username, password: @settings.password}
        )
        feed = response.parsed_response
        logger.debug "Cal1Card remote response: #{response.inspect}"
      end
      camelized = HashConverter.camelize feed
      camelized[:cal1card].merge({
        statusCode: 200
      })
    end

  end
end

