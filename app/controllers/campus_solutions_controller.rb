class CampusSolutionsController < ApplicationController

  before_filter :api_authenticate

  def country
    render json: CampusSolutions::Country.new.get
  end

end
