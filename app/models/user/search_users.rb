module User
  class SearchUsers
    extend Cache::Cacheable

    def initialize(options={})
      @id = options[:id]
    end

    def search_users
      self.class.fetch_from_cache "#{@id}" do
        users_uid = User::SearchUsersByUid.new(id: @id).search_users_by_uid
        users_sid = User::SearchUsersBySid.new(id: @id).search_users_by_sid
        users_uid + users_sid
      end
    end

  end
end
