class CampusSolutionsController < ApplicationController
  before_filter :api_authenticate_401

  def json_passthrough(classname, params={})
    render(json:(classname.new(params).get))
  end

  def post_passthrough(classname)
    model = classname.from_session(session)
    render json: model.update(request.request_parameters)
  end

end
