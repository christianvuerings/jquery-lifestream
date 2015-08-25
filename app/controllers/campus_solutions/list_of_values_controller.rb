class ListOfValuesController < CampusSolutionsController

  def get
    json_passthrough(CampusSolutions::ListOfValues, {params: {fieldName: params['fieldName'], recordName: params['recordName']}})
  end

end
