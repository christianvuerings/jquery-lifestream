module User
  class Api < UserSpecificModel
    include ActiveRecordHelper
    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher
    include CampusSolutions::ProfileFeatureFlagged
    include ClassLogger

    def init
      use_pooled_connection {
        @calcentral_user_data ||= User::Data.where(:uid => @uid).first
      }
      @oracle_attributes ||= CampusOracle::UserAttributes.new(user_id: @uid).get_feed
      if is_cs_profile_feature_enabled
        @edo_attributes ||= HubEdos::UserAttributes.new(user_id: @uid).get
      end
      @default_name ||= get_campus_attribute('person_name')
      @first_login_at ||= @calcentral_user_data ? @calcentral_user_data.first_login_at : nil
      @first_name ||= get_campus_attribute('first_name') || ""
      @last_name ||= get_campus_attribute('last_name') || ""
      @override_name ||= @calcentral_user_data ? @calcentral_user_data.preferred_name : nil
      @student_id = get_campus_attribute('student_id')
    end

    # split brain until SIS GoLive5 makes registration data available
    def get_campus_attribute(field)
      value = nil
      if is_sis_profile_visible? && @edo_attributes[:noStudentId].blank?
        value = @edo_attributes[field.to_sym]
      end
      if value.nil?
        value = @oracle_attributes[field]
      end
      value
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

    def is_campus_solutions_student?
      # no, really, BCS users are identified by having 10-digit IDs.
      @student_id.to_s.length >= 10
    end

    def is_sis_profile_visible?
      is_cs_profile_feature_enabled && (is_campus_solutions_student? || is_profile_visible_for_legacy_users)
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
      roles = (get_campus_attribute(:roles)) ? get_campus_attribute(:roles) : {}
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
        :inEducationAbroadProgram => @oracle_attributes[:education_abroad],
        :googleEmail => google_mail,
        :canvasEmail => canvas_mail,
        :last_name => @last_name,
        :preferred_name => self.preferred_name,
        :roles => get_campus_attribute(:roles),
        :uid => @uid,
        :sid => @student_id,
        :isCampusSolutionsStudent => is_campus_solutions_student?,
        :showSisProfileUI => is_sis_profile_visible?
      }
    end

  end
end
