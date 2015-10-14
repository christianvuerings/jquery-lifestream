module CampusSolutions
  class MyLanguage < UserSpecificModel

    include PersonDataUpdatingModel

    def update(params = {})
      passthrough(CampusSolutions::LanguagePost, params)
    end

    def delete(params = {})
      passthrough(CampusSolutions::LanguageDelete, params)
    end

  end
end
