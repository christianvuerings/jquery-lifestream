class WorkExperienceController < CampusSolutionsController

  def post
    render json: CampusSolutions::MyWorkExperience.from_session(session).update(params)
  end

end
