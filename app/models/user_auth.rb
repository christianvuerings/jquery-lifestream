class UserAuth < ActiveRecord::Base
  include ActiveRecordHelper

  after_initialize :log_access
  attr_accessible :uid, :is_superuser, :is_test_user, :active

  def self.is_superuser?(uid)
    use_pooled_connection {
      !(self.where(:uid => uid, :is_superuser => true, :active => true).first).blank?
    }
  end

  def self.new_or_update_superuser!(uid)
    use_pooled_connection {
      user = self.where(uid: uid).first_or_initialize
      #super-user and test-user flags should probably be mutually exclusive...
      user.is_superuser = true
      user.is_test_user = false
      user.active = true
      user.save
    }
  end


  def self.is_test_user?(uid)
    use_pooled_connection {
      !(self.where(:uid => uid, :is_test_user => true, :active => true).first).blank?
    }
  end

  def self.new_or_update_test_user!(uid)
    use_pooled_connection {
      user = self.where(uid: uid).first_or_initialize
      user.is_superuser = false
      user.is_test_user = true
      user.active = true
      user.save
    }
  end
end
