class StateController < CampusSolutionsController

  def state
    render json: CampusSolutions::State.new.get
  end

end
