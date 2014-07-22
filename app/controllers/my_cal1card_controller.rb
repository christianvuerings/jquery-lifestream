class MyCal1cardController < ApplicationController

  before_filter :api_authenticate

  def get_feed
    render json: Cal1card::MyCal1card.from_session(session).get_feed_as_json
  end

end
