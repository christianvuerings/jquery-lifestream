module CampusSolutions
  class DepositController < CampusSolutionsController

    def get
      model = CampusSolutions::MyDeposit.from_session(session)
      model.adm_appl_nbr = params['adm_appl_nbr']
      render json: model.get_feed_as_json
    end

  end
end
