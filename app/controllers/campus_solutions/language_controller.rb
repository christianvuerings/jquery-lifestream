class LanguageController < CampusSolutionsController

  def get
    json_passthrough CampusSolutions::Language
  end

end
