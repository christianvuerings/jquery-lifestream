class UserData < ActiveRecord::Base
  attr_accessible :preferred_name, :uid, :first_login_at
end
