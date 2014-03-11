module Canvas
  class Canvas::CanvasUsersReportProxy < Canvas::CanvasReportProxy
    require 'csv'

    def get_csv
      get_provisioning_csv('users')
    end

  end
end
