class CampusSolutionsController < ApplicationController

  before_filter :api_authenticate

  def country
    render json: CampusSolutions::Country.new.get
  end

  def state
    render json: CampusSolutions::State.new.get
  end

end
