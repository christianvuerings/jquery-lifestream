class MyTextbooksController < ApplicationController

  def get_feed
    if session[:user_id]
      render json: Proxy.new({ccns: params[:ccns], slug: params[:slug]}).get_as_json
    else
      render json: {}.to_json
    end
  end

end
