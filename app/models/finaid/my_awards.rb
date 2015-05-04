module Finaid
  class MyAwards < UserSpecificModel
    include ClassLogger

    def append_feed!(feed)
      feed[:awards] = []
      if Settings.features.cs_fin_aid
        append!(feed)
      end
      feed
    end

    def append!(feed)
      begin
        proxy = CampusSolutions::Awards.new({user_id: @uid})
        feed[:awards] = proxy.get[:feed]
      rescue => e
        self.class.handle_exception(e, self.class.cache_key(@uid), {
                                       id: @uid,
                                       user_message_on_exception: "Remote server unreachable",
                                       return_nil_on_generic_error: true
                                     })
      end
    end
  end
end
