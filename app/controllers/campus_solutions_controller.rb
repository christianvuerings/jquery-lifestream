class CampusSolutionsController < ApplicationController
  before_filter :api_authenticate_401

  def json_passthrough(classname)
    render json: classname.new.get
  end
end
