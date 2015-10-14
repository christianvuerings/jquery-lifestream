module CampusSolutions
  class TermsAndConditionsController < CampusSolutionsController

    before_filter :exclude_acting_as_users

    def post
      model = CampusSolutions::MyTermsAndConditions.from_session(session)
      render json: model.update(request.request_parameters)
    end

  end
end
