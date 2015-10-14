module CampusSolutions
  class MyEmail < UserSpecificModel

    include PersonDataUpdatingModel

    def update(params = {})
      passthrough(CampusSolutions::Email, params)
    end

    def delete(params = {})
      passthrough(CampusSolutions::EmailDelete, params)
    end

  end
end
