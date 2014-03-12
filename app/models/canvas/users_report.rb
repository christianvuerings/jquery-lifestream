module Canvas
  class UsersReport < Canvas::Report
    require 'csv'

    def get_csv
      get_provisioning_csv('users')
    end

  end
end
