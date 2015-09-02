module CampusSolutions
  class MyPhone < UserSpecificModel

    include PersonDataUpdatingModel

    def update(params = {})
      passthrough(CampusSolutions::Phone, params)
    end

    def delete(params = {})
      passthrough(CampusSolutions::PhoneDelete, params)
    end

  end
end
