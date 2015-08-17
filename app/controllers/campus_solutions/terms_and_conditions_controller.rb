class TermsAndConditionsController < CampusSolutionsController

  def post
    model = CampusSolutions::MyTermsAndConditions.from_session(session)
    render json: model.update(request.request_parameters)
  end

end
