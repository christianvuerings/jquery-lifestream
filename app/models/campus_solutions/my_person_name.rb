module CampusSolutions
  class MyPersonName < UserSpecificModel

    include PersonDataUpdatingModel

    def update(params = {})
      passthrough(CampusSolutions::PersonName, params)
    end

    def delete(params = {})
      passthrough(CampusSolutions::NameDelete, params)
    end

  end
end
