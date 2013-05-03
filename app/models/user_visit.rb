class UserVisit < ActiveRecord::Base

  include ActiveRecordHelper

  after_initialize :log_access
  attr_accessible :uid, :last_visit_at

  def record_timestamps
    false
  end

  self.primary_key = :uid

  def self.record(uid)
    use_pooled_connection {
      visit = self.where(uid: uid).first_or_initialize
      visit.last_visit_at = DateTime.now
      visit.save
    }
  end

end
