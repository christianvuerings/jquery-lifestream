class MyFinancialsController < ApplicationController

  before_filter :api_authenticate

  def get_feed
    render json: Financials::MyFinancials.new(session[:user_id], original_user_id: session[:original_user_id]).get_feed
  end

end
