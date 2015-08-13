class AidYearsController < CampusSolutionsController

  def aid_years
    render json: CampusSolutions::MyAidYears.from_session(session).get_feed_as_json
  end

end
