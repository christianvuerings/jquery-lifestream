class MyCal1cardController < ApplicationController

  def get_feed
    if session[:user_id]
      render json: Cal1card::MyCal1card.new(session[:user_id], original_user_id: session[:original_user_id]).get_feed_as_json
    else
      render json: {}.to_json
    end
  end

end
