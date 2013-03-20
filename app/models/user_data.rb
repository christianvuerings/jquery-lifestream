class UserData < ActiveRecord::Base
  include ActiveRecordHelper

  after_initialize :log_access
  attr_accessible :preferred_name, :uid, :first_login_at
end
