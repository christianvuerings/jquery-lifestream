module Canvas
  class UsersReport < Canvas::Report
    require 'csv'

    def report_retrieval_attempts
      360
    end

    def object_type
      'users'
    end

  end
end
