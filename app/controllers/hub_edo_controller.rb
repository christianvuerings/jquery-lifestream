class HubEdoController < ApplicationController
  before_filter :api_authenticate_401

  def person
    json_passthrough HubEdos::MyPerson
  end

  def student
    json_passthrough HubEdos::MyStudent
  end

  def work_experience
    json_passthrough HubEdos::MyWorkExperience
  end

  def json_passthrough(classname)
    model = classname.from_session session
    render json: model.get_feed_as_json
  end

end
