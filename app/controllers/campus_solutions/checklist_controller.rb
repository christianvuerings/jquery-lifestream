module CampusSolutions
  class ChecklistController < CampusSolutionsController

    def get
      json_passthrough(CampusSolutions::Checklist)
    end

  end
end
