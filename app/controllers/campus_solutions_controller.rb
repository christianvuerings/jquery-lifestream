class CampusSolutionsController < ApplicationController
  before_filter :api_authenticate_401

  def json_passthrough(classname, params={})
    render(json:(classname.new(params).get))
  end
end
