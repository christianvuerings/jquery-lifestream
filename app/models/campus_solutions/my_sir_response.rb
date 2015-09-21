module CampusSolutions
  class MySirResponse < UserSpecificModel

    include PersonDataUpdatingModel

    def update(params = {})
      CampusSolutions::Checklist.expire @uid
      passthrough(CampusSolutions::SirResponse, params)
    end

  end
end
