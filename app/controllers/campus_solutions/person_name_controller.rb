class PersonNameController < CampusSolutionsController

  def post
    post_passthrough CampusSolutions::MyPersonName
  end

end
