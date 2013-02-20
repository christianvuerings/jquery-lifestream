class UserAuth < ActiveRecord::Base
  attr_accessible :uid, :is_superuser, :active

  def self.is_superuser?(uid)
    !(self.where(:uid => uid, :is_superuser => true, :active => true).first).blank?
  end

  def self.new_or_update_superuser!(uid)
    user = self.where(uid: uid).first_or_initialize
    user.is_superuser = true
    user.active = true
    user.save
  end

end
