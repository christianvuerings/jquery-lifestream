class TermsAndConditionsController < CampusSolutionsController

  def terms_and_conditions
    model = CampusSolutions::MyTermsAndConditions.from_session(session)
    render json: model.update(request.request_parameters)
  end

end
