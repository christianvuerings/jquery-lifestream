class CalcentralConfigController < ApplicationController
  before_filter :get_settings, :initialize_calcentral_config

  def get
    render json: @calcentral_config.merge({
      # See http://git.io/rgw3Pg
      csrfParam: request_forgery_protection_token,
      csrfToken: form_authenticity_token
    }).to_json.html_safe
  end

end
