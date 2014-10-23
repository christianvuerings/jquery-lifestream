module User
  class SearchUsersBySid
    extend Cache::Cacheable

    def initialize(options={})
      @id = options[:id]
    end

    def search_users_by_sid
      self.class.fetch_from_cache "#{@id}" do
        CampusOracle::Queries.find_people_by_student_id(@id)
      end
    end

  end
end
