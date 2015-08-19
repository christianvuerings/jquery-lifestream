class LanguageController < CampusSolutionsController

  def post
    post_passthrough CampusSolutions::MyLanguagePost
  end

end
