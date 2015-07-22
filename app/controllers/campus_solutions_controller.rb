class CampusSolutionsController < ApplicationController

  before_filter :api_authenticate_401

  def country
    render json: CampusSolutions::Country.new.get
  end

  def state
    render json: CampusSolutions::State.new.get
  end

  def address
    render json: CampusSolutions::MyAddress.from_session(session).get_feed_as_json
  end

  def update_address
    render json: CampusSolutions::MyAddress.from_session(session).update(params)
  end

  def aid_years
    render json: CampusSolutions::MyAidYears.from_session(session).get_feed_as_json
  end

  def financial_data
    model = CampusSolutions::MyFinancialData.from_session(session)
    model.aid_year = params['aid_year']
    render json: model.get_feed_as_json
  end

end
