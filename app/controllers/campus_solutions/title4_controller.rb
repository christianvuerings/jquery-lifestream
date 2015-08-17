class Title4Controller < CampusSolutionsController

  def post
    model = CampusSolutions::MyTitle4.from_session(session)
    render json: model.update(request.request_parameters)
  end

end
