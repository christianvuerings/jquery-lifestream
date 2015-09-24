module CampusSolutions
  class MySirResponse < UserSpecificModel

    include PersonDataUpdatingModel

    def update(params = {})
      ChecklistDataExpiry.expire @uid
      passthrough(CampusSolutions::SirResponse, params)
    end

  end
end
