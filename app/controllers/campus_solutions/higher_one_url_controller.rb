module CampusSolutions
  class HigherOneUrlController < CampusSolutionsController

    def get
      model = CampusSolutions::MyHigherOneUrl.from_session(session)
      render json: model.get_feed_as_json
    end

  end
end

