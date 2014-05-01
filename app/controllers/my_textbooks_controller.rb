class MyTextbooksController < ApplicationController

  before_filter :api_authenticate

  def get_feed
    render json: Textbooks::Proxy.new({ccns: params[:ccns], slug: params[:slug]}).get_as_json
  end

end
