class StateController < CampusSolutionsController

  def get
    json_passthrough CampusSolutions::State
  end

end
