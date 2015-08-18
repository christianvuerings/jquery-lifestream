class NameTypeController < CampusSolutionsController

  def get
    json_passthrough CampusSolutions::NameType
  end

end
