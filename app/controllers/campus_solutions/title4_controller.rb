module CampusSolutions
  class Title4Controller < CampusSolutionsController

    before_filter :exclude_acting_as_users

    def post
      model = CampusSolutions::MyTitle4.from_session(session)
      render json: model.update(request.request_parameters)
    end

  end
end
