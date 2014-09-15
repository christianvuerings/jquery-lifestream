module User
  class Api < UserSpecificModel
    include ActiveRecordHelper
    include Cache::LiveUpdatesEnabled
    include ClassLogger

    def init
      use_pooled_connection {
        @calcentral_user_data ||= User::Data.where(:uid => @uid).first
      }
      @campus_attributes ||= CampusOracle::UserAttributes.new(user_id: @uid).get_feed
      @default_name ||= @campus_attributes['person_name']
      @first_login_at ||= @calcentral_user_data ? @calcentral_user_data.first_login_at : nil
      @first_name ||= @campus_attributes['first_name'] || ""
      @last_name ||= @campus_attributes['last_name'] || ""
      @override_name ||= @calcentral_user_data ? @calcentral_user_data.preferred_name : nil
    end

    def preferred_name
      @override_name || @default_name || ""
    end

    def preferred_name=(val)
      if val.blank?
        val = nil
      else
        val.strip!
      end
      @override_name = val
    end

    def self.delete(uid)
      logger.warn "Removing all stored user data for user #{uid}"
      user = nil
      use_pooled_connection {
        Calendar::User.delete_all({uid: uid})
        user = User::Data.where(:uid => uid).first
        if !user.blank?
          user.delete
        end
      }
      if !user.blank?
        GoogleApps::Revoke.new(user_id: uid).revoke
        use_pooled_connection {
          User::Oauth2Data.destroy_all(:uid => uid)
          Notifications::Notification.destroy_all(:uid => uid)
        }
      end

      Cache::UserCacheExpiry.notify uid
    end

    def save
      use_pooled_connection {
        Retriable.retriable(:on => ActiveRecord::RecordNotUnique, :tries => 5) do
          @calcentral_user_data = User::Data.where(uid: @uid).first_or_create do |record|
            logger.debug "Recording first login for #{@uid}"
            record.preferred_name = @override_name
            record.first_login_at = @first_login_at
          end
          if @calcentral_user_data.preferred_name != @override_name
            @calcentral_user_data.update_attribute(:preferred_name, @override_name)
          end
        end
      }
      Cache::UserCacheExpiry.notify @uid
    end

    def update_attributes(attributes)
      init
      if attributes.has_key?(:preferred_name)
        self.preferred_name = attributes[:preferred_name]
      end
      save
    end

    def record_first_login
      init
      @first_login_at = DateTime.now
      save
    end

    def get_feed_internal
      google_mail = User::Oauth2Data.get_google_email(@uid)
      canvas_mail = User::Oauth2Data.get_canvas_email(@uid)
      current_user_policy = authentication_state.policy
      is_google_reminder_dismissed = User::Oauth2Data.is_google_reminder_dismissed(@uid)
      is_google_reminder_dismissed = is_google_reminder_dismissed && is_google_reminder_dismissed.present?
      is_calendar_opted_in = Calendar::User.where(:uid => @uid).first.present?
      has_student_history = CampusOracle::UserCourses::HasStudentHistory.new({:user_id => @uid}).has_student_history?
      has_instructor_history = CampusOracle::UserCourses::HasInstructorHistory.new({:user_id => @uid}).has_instructor_history?
      roles = (@campus_attributes && @campus_attributes[:roles]) ? @campus_attributes[:roles] : {}
      {
        :isSuperuser => current_user_policy.can_administrate?,
        :isViewer => current_user_policy.can_view_as?,
        :firstLoginAt => @first_login_at,
        :first_name => @first_name,
        :fullName => @first_name + ' ' + @last_name,
        :isGoogleReminderDismissed => is_google_reminder_dismissed,
        :isCalendarOptedIn => is_calendar_opted_in,
        :hasCanvasAccount => Canvas::Proxy.has_account?(@uid),
        :hasGoogleAccessToken => GoogleApps::Proxy.access_granted?(@uid),
        :hasStudentHistory => has_student_history,
        :hasInstructorHistory => has_instructor_history,
        :hasAcademicsTab => (
        roles[:student] || roles[:faculty] ||
          has_instructor_history || has_student_history
        ),
        :hasFinancialsTab => (roles[:student] || roles[:exStudent]),
        :hasPhoto => User::Photo.has_photo?(@uid),
        :googleEmail => google_mail,
        :canvasEmail => canvas_mail,
        :last_name => @last_name,
        :preferred_name => self.preferred_name,
        :roles => @campus_attributes[:roles],
        :uid => @uid
      }
    end

  end
end
