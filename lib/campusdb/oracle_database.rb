class OracleDatabase < ActiveRecord::Base
  establish_connection "campusdb"

  def self.test_data?
    Settings.campusdb.adapter == "h2"
  end

end
