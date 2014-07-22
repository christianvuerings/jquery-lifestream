class MyFinancialsController < ApplicationController

  before_filter :api_authenticate

  def get_feed
    render json: Financials::MyFinancials.from_session(session).get_feed
  end

end
