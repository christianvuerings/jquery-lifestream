class AddressController < CampusSolutionsController

  def get
    render json: CampusSolutions::MyAddress.from_session(session).get_feed_as_json
  end

  def post
    render json: CampusSolutions::MyAddress.from_session(session).update(params)
  end

end
