class HubEdoController < ApplicationController
  before_filter :api_authenticate_401

  def person
    model = HubEdos::MyPerson.from_session(session)
    render json: model.get_feed_as_json
  end

end
