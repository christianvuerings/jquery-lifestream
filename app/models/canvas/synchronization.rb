module Canvas
  # Provides object used to store synchronization states between campus systems and Canvas
  class Synchronization < ActiveRecord::Base
    include ActiveRecordHelper

    self.table_name = 'canvas_synchronization'
    attr_accessible :last_guest_user_sync
    attr_accessible :latest_term_enrollment_csv_set

    # Returns single record used to store synchronization timestamp(s)
    def self.get
      raise RuntimeError, "Canvas synchronization data is missing" if self.count == 0
      self.first
    end
  end
end
