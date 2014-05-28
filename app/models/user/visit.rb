module User
  class Visit < ActiveRecord::Base

    include ActiveRecordHelper

    self.table_name = 'user_visits'

    after_initialize :log_access
    attr_accessible :uid, :last_visit_at

    def record_timestamps
      false
    end

    self.primary_key = :uid

    def self.record(uid)
      use_pooled_connection {
        Retriable.retriable(:on => ActiveRecord::RecordNotUnique, :tries => 5) do
          visit = self.where(uid: uid).first_or_initialize
          visit.last_visit_at = DateTime.now
          visit.save
        end
      }
    end

  end
end
