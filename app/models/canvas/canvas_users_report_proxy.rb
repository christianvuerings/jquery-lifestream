class CanvasUsersReportProxy  < CanvasReportProxy
  require 'csv'

  def get_csv
    get_provisioning_csv('users')
  end

end
