class UserAuth < ActiveRecord::Base
  attr_accessible :uid, :acting_as_uid, :is_superuser, :active

  def self.is_superuser?(uid)
    !(self.where(:uid => uid, :is_superuser => true, :active => true).first).blank?
  end

  def self.can_act_as?(uid, acting_as_uid)
    !(self.where(:uid => uid, :acting_as_uid => acting_as_uid, :active => true).first).blank?
  end

  def self.new_or_update_superuser!(uid)
    user = self.where(uid: uid, acting_as_uid: '').first_or_initialize
    user.is_superuser = true
    user.active = true
    user.save
  end

  def self.new_or_update_act_as!(uid, acting_as_uid)
    user = UserAuth.where(:uid => uid, :acting_as_uid => acting_as_uid).first_or_initialize
    user.is_superuser = false
    user.active = true
    user.save
  end
end
