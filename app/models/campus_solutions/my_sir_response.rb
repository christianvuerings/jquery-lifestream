module CampusSolutions
  class MySirResponse < UserSpecificModel

    include PersonDataUpdatingModel

    def update(params = {})
      passthrough(CampusSolutions::SirResponse, params)
    end

  end
end
