class EmailController < CampusSolutionsController

  def post
    post_passthrough CampusSolutions::MyEmail
  end

end
