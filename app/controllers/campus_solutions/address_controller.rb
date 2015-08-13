class AddressController < CampusSolutionsController

  def address
    render json: CampusSolutions::MyAddress.from_session(session).get_feed_as_json
  end

  def update_address
    render json: CampusSolutions::MyAddress.from_session(session).update(params)
  end

end
