class EmailController < CampusSolutionsController

  def post
    post_passthrough CampusSolutions::Models::MyEmail
  end

end
