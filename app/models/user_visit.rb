class UserVisit < ActiveRecord::Base

  include ActiveRecordHelper

  set_primary_key :uid
  after_initialize :log_access
  attr_accessible :uid, :last_visit_at

  def record_timestamps
    false
  end

  def self.record(uid)
    visit = self.where(uid: uid).first_or_initialize
    visit.last_visit_at = DateTime.now
    visit.save
  end

end
