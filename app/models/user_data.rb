class UserData < ActiveRecord::Base
  attr_accessible :preferred_name, :uid, :first_login_at, :is_test_user

  def self.is_test_user?(uid)
    self.where(:uid => uid, :is_test_user => true).first
  end
end
