module CampusSolutions
  class StateController < CampusSolutionsController

    def get
      json_passthrough(CampusSolutions::State, {country: params['country']})
    end

  end
end
