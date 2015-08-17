class TranslateController < CampusSolutionsController

  def get
    json_passthrough CampusSolutions::Translate
  end

end
