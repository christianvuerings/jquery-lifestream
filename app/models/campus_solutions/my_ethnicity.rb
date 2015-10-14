module CampusSolutions
  class MyEthnicity < UserSpecificModel

    include PersonDataUpdatingModel

    def update(params = {})
      passthrough(CampusSolutions::EthnicityPost, params)
    end

    def delete(params = {})
      passthrough(CampusSolutions::EthnicityDelete, params)
    end

  end
end
