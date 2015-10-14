module CampusSolutions
  class FinancialAidDataController < CampusSolutionsController

    def get
      model = CampusSolutions::MyFinancialAidData.from_session(session)
      model.aid_year = params['aid_year']
      render json: model.get_feed_as_json
    end

  end
end
