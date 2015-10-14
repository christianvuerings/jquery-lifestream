module CampusSolutions
  class MyAddress < UserSpecificModel

    include PersonDataUpdatingModel

    def update(params = {})
      passthrough(CampusSolutions::Address, params)
    end

    def delete(params = {})
      passthrough(CampusSolutions::AddressDelete, params)
    end

  end
end
