module Webcast
  class Rooms < Proxy

    def initialize(options = {})
      super(options)
    end

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

    def any_in_webcast_enabled_room?(ccn_list)
      raise RuntimeError, 'Method not implemented'
    end

  end
end
