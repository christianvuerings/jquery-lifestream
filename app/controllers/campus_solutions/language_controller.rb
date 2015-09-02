module CampusSolutions
  class LanguageController < CampusSolutionsController

    def post
      post_passthrough CampusSolutions::MyLanguage
    end

    def delete
      delete_passthrough CampusSolutions::MyLanguage
    end

  end
end
