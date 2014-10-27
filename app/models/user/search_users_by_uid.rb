module User
  class SearchUsersByUid
    extend Cache::Cacheable

    def initialize(options={})
      @id = options[:id]
    end

    def search_users_by_uid
      self.class.fetch_from_cache "#{@id}" do
        CampusOracle::Queries.find_people_by_uid(@id)
      end
    end

  end
end
