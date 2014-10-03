module HttpRequester
  def verify_ssl?
    Settings.application.layer == 'production'
  end

  # HTTParty is our preferred HTTP connectivity lib. Use this get_response method wherever possible.
  def get_response(url, additional_options={})
    ActiveSupport::Notifications.instrument('proxy', {url: url, class: self.class}) do
      HTTParty.get(
        url,
        {
          timeout: Settings.application.outgoing_http_timeout,
          verify: verify_ssl?
        }.merge(additional_options)
      )
    end
  end
end
