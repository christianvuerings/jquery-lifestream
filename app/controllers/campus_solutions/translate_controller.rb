module CampusSolutions
  class TranslateController < CampusSolutionsController

    def get
      json_passthrough(CampusSolutions::Translate, {field_name: params['field_name']})
    end

  end
end
