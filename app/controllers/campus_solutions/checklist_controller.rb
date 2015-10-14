module CampusSolutions
  class ChecklistController < CampusSolutionsController

    def get
      render json: CampusSolutions::MyChecklist.from_session(session).get_feed_as_json
    end

  end
end
