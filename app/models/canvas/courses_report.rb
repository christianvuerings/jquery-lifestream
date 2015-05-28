module Canvas
  class CoursesReport < Report

    def get_csv(term_id)
      get_provisioning_csv('courses', term_id)
    end

  end
end
