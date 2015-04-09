module Mediacasts
  class Rooms < Proxy

    def initialize(term_yr, term_cd, options = {})
      super(options)
      @term_yr = term_yr
      @term_cd = term_cd.upcase
    end

    def get_json_path
      "#{@term_yr}/#{@term_cd}/rooms.json"
    end

    def request_internal
      return {} unless Settings.features.videos
      data = get_json_data
      building_map = {
      }
      data['webcastEnabledRooms'].each do |data_element|
        building_map[data_element['building']] = data_element['rooms']
      end
      building_map
    end

  end
end
