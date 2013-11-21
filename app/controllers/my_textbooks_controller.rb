class MyTextbooksController < ApplicationController

  def get_feed
  	ccns = params[:ccns]
    slug = params[:slug]
  	if session[:user_id]
      	render json: MyTextbooks.new(session[:user_id], ccns: ccns, slug: slug).get_feed_as_json
    else
      	render json: {}.to_json
  	end
  end

end
