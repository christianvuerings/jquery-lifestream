module CampusSolutions
  class WorkExperienceController < CampusSolutionsController

    before_filter :exclude_acting_as_users

    def post
      render json: CampusSolutions::MyWorkExperience.from_session(session).update(params)
    end

  end
end
