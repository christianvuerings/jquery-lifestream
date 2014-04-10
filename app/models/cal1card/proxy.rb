module Cal1card
  class Proxy < BaseProxy

    include ClassLogger

    def initialize(options = {})
      super(Settings.cal1card_proxy, options)
    end

    def get
      self.class.smart_fetch_from_cache(
        {
          id: @uid
        }) do
        internal_get
      end
    end

    private

    def internal_get
      json = xml_to_json(get_raw_xml)

      status_code = 200
      logger.info "Cal1card data: #{json}, remote server status #{status_code}"
      {
        body: json,
        statusCode: status_code
      }
    end

    def get_raw_xml
      if @fake
        logger.info "Fake = #@fake, getting data from XML fixture file; user #{@uid}; cache expiration #{self.class.expires_in}"
        File.read(Rails.root.join('fixtures', 'xml', 'cal1card_feed.xml').to_s)
      else
        logger.info "Fake = #@fake; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
        #TODO implement real HTTP
        ''
      end
    end

    def xml_to_json(xml)
      hash = Hash.from_xml(xml)
      camelized = HashConverter.camelize hash
      camelized.to_json
    end

  end
end
