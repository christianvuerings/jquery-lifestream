module User
  class SearchUsers

    def self.search_users(id)
      feed1 = CampusOracle::Queries.find_people_by_uid(id)
      feed2 = CampusOracle::Queries.find_people_by_student_id(id)
      feed1 + feed2
    end

  end
end
