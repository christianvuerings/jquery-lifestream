module User
  class Auth < ActiveRecord::Base
    include ActiveRecordHelper

    self.table_name = 'user_auths'

    after_initialize :log_access
    attr_accessible :uid, :is_superuser, :is_author, :is_viewer, :active

    def self.get(uid)
      user_auth = uid.nil? ? nil : User::Auth.where(:uid => uid.to_s).first
      if user_auth.blank?
        # user's anonymous, or is not in the user_auth table, so give them an active status with zero permissions.
        user_auth = User::Auth.new(uid: uid, is_superuser: false, is_author: false, is_viewer: false, active: true)
      end
      user_auth
    end

    def self.new_or_update_superuser!(uid)
      use_pooled_connection {
        Retriable.retriable(:on => ActiveRecord::RecordNotUnique, :tries => 5) do
          user = self.where(uid: uid).first_or_initialize
          #super-user and test-user flags should probably be mutually exclusive...
          user.is_superuser = true
          user.active = true
          user.save
        end
      }
    end

  end
end
