module User
  class SearchUsers
    extend Cache::Cacheable

    def initialize(options={})
      @id = options[:id]
    end

    def search_users
      self.class.fetch_from_cache "#{@id}" do
        feed1 = CampusOracle::Queries.find_people_by_uid(@id)
        feed2 = CampusOracle::Queries.find_people_by_student_id(@id)
        feed1 + feed2
      end
    end

  end
end
