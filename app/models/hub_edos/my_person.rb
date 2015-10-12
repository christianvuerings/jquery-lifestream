module HubEdos
  class MyPerson < UserSpecificModel

    include ClassLogger
    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher
    include User::Student

    def get_feed_internal
      cs_id = lookup_campus_solutions_id
      cs_id.present? ? HubEdos::Student.new({user_id: @uid}).get : HubEdos::Person.new({user_id: @uid}).get
    end

  end
end
