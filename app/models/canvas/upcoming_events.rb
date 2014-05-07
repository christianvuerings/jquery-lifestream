module Canvas
  class UpcomingEvents < Proxy

    include Cache::UserCacheExpiry

    def upcoming_events
      request("users/self/upcoming_events?as_user_id=sis_login_id:#{@uid}", "_upcoming_events")
    end

  end
end
