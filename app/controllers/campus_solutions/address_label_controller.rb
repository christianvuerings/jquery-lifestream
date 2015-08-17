class AddressLabelController < CampusSolutionsController

  def get
    json_passthrough CampusSolutions::AddressLabel
  end

end
