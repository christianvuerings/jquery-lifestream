class FinancialAidDataController < CampusSolutionsController

  def financial_aid_data
    model = CampusSolutions::MyFinancialAidData.from_session(session)
    model.aid_year = params['aid_year']
    render json: model.get_feed_as_json
  end

end
