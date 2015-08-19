class AddressController < CampusSolutionsController

  def post
    render json: CampusSolutions::MyAddress.from_session(session).update(params)
  end

end
