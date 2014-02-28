class MyTextbooksController < ApplicationController

  def get_feed
    if session[:user_id]
      ccns = params[:ccns]
      slug = params[:slug]
      proxy = TextbooksProxy.new({ccns: ccns, slug: slug})
      render json: proxy.get_as_json
    else
      render json: {}.to_json
    end
  end

end
