class LanguageController < CampusSolutionsController

  def get
    json_passthrough CampusSolutions::Language
  end

  def post
    post_passthrough CampusSolutions::MyLanguagePost
  end

end
