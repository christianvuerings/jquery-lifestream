module User
  class Photo
    extend Cache::Cacheable

    def self.fetch(uid)
      smart_fetch_from_cache({id: uid, user_message_on_exception: "Photo server unreachable"}) do
        CampusOracle::Queries.get_photo(uid)
      end
    end

    def self.has_photo?(uid)
      !!User::Photo.fetch(uid)
    end

  end
end
