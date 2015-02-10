module User
  class SearchUsersByUid
    extend Cache::Cacheable

    def initialize(options={})
      @id = options[:id]
      @ids = options[:ids]
    end

    def search_users_by_uid
      search_batch([@id])
    end

    def search_users_by_uid_batch
      search_batch(@ids)
    end

    private

    def search_batch(uids)
      cache_key = uids.sort.join('-')
      self.class.fetch_from_cache "#{cache_key}" do
        CampusOracle::Queries.get_basic_people_attributes(uids)
      end
    end

  end
end
