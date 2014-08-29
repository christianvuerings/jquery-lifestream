module Financials
  # This Proxy class gets data from the external CFV HTTP service.
  class Proxy < BaseProxy
    include ClassLogger

    # APP_ID must be unique within the system, and is used by VCR and the front-end in various ways.
    APP_ID = 'CFV'

    def initialize(options = {})
      super(Settings.financials_proxy, options)
      @student_id = options[:student_id]
    end

    def get
      url = "#{Settings.financials_proxy.base_url}/student/#{@student_id}"
      logger.info "Fake = #@fake; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"

      # HTTParty is our preferred HTTP library. FakeableProxy provides the (deprecated) VCR response recording system.
      response = ActiveSupport::Notifications.instrument('proxy', { url: url, class: self.class }) do
        FakeableProxy.wrap_request(APP_ID + "_financials", @fake, {match_requests_on: [:method, :path]}) {
          HTTParty.get(
            url,
            digest_auth: {username: Settings.financials_proxy.username, password: Settings.financials_proxy.password},
            timeout: Settings.application.outgoing_http_timeout,
            verify: verify_ssl?
          )
        }
      end
      response
    end

  end
end
