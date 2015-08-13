class CountryController < CampusSolutionsController

  def country
    render json: CampusSolutions::Country.new.get
  end

end
