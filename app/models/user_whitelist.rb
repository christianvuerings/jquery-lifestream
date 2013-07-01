class UserWhitelist < ActiveRecord::Base

  attr_accessible :uid

  validates :uid, :presence => true
  validates_uniqueness_of :uid

end
