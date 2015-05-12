module Webcast
  class Rooms < Proxy

    def get_json_path
      'rooms.json'
    end

    def request_internal
      return {} unless Settings.features.videos
      data = get_json_data
      building_map = {}
      data['webcastEnabledRooms'].each do |data_element|
        building_map[data_element['building']] = data_element['rooms']
      end
      building_map
    end

    def includes_any?(rooms)
      in_webcast_enabled = false
      rooms.each do |room|
        building = room['building']
        webcast_enabled_in_building = building && get[building.upcase]
        if webcast_enabled_in_building
          in_webcast_enabled = webcast_enabled_in_building.include? room['number'].to_s
          break if in_webcast_enabled
        end
      end
      in_webcast_enabled
    end

  end
end
