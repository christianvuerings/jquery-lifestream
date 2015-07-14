module CanvasLti
  require 'ims/lti'
  require 'ims/lti/extensions'
  require 'oauth/request_proxy/rack_request'

  class Lti
    extend Cache::Cacheable
    include ClassLogger

    LTI_SELECTION_DIRECTIVES = {
      'embed_content' => %w(image iframe link basic_lti oembed),
      'select_link' => ['basic_lti'],
      'submit_homework' => %w(link file)
    }

    def initialize
      @lti_key = Settings.canvas_proxy.lti_key
      @lti_secret = Settings.canvas_proxy.lti_secret
    end

    # Check timestamp and nonce, and then try to parse the request.
    def validate_tool_provider(request)
      params = request.request_parameters
      logger.debug "LTI params = #{params.inspect}"
      current_time = Time.new
      timestamp = params['oauth_timestamp']
      if !timestamp.blank?
        timestamp = Time.at(timestamp.to_i)
        if timestamp > (current_time - 300) && timestamp < (current_time + 300)
          nonce_check = params['oauth_nonce']
          if !nonce_check.blank?
            if !self.class.in_cache?(nonce_check)
              Rails.cache.write(self.class.cache_key(nonce_check), timestamp, expires_id: self.class.expires_in)
              request_key = params['oauth_consumer_key']
              if @lti_key == request_key
                lti = IMS::LTI::ToolProvider.new(request_key, @lti_secret, params)
                lti.extend IMS::LTI::Extensions::OutcomeData::ToolProvider
                lti.extend IMS::LTI::Extensions::Content::ToolProvider
                begin
                  lti.valid_request?(request)
                  return lti
                rescue => e
                  logger.warn "LTI request was invalid: #{e.message}"
                end
              else
                logger.warn 'LTI unrecognized consumer key'
              end
            else
              logger.warn "LTI repeated nonce = #{params['oauth_nonce']}"
            end
          end
        else
          logger.warn "LTI timestamp outdated: raw = #{params['oauth_timestamp']}, parsed = #{timestamp}"
        end
      end
      nil
    end

  end
end
