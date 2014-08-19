module Canvas
  class UsersReport < Canvas::Report
    require 'csv'

    def get_csv
      get_provisioning_csv('users')
    end

    def report_retrieval_attempts
      360
    end

  end
end
