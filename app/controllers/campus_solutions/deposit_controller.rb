module CampusSolutions
  class DepositController < CampusSolutionsController

    def get
      model = CampusSolutions::MyDeposit.from_session(session)
      model.adm_appl_nbr = params['admApplNbr']
      render json: model.get_feed_as_json
    end

  end
end
