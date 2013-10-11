class UserApi < MyMergedModel
  include ActiveRecordHelper

  def initialize(uid)
    super(uid)
  end

  def init
    use_pooled_connection {
      @calcentral_user_data ||= UserData.where(:uid => @uid).first
    }
    @campus_attributes ||= CampusData.get_person_attributes(@uid) || {}
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
    logger.info "#{self.class.name} removing user #{uid} from UserData"
    user = nil
    use_pooled_connection {
      user = UserData.where(:uid => uid).first
      if !user.blank?
        user.delete
      end
    }
    if !user.blank?
      # The nice way to do this is to also revoke their tokens by sending revoke request to the remote services
      use_pooled_connection {
        Oauth2Data.destroy_all(:uid => uid)
        Notification.destroy_all(:uid => uid)
      }
    end

    Calcentral::USER_CACHE_EXPIRATION.notify uid
  end

  def save
    use_pooled_connection {
      retriable(:on => ActiveRecord::RecordNotUnique, :tries => 5) do
        @calcentral_user_data = UserData.where(uid: @uid).first_or_create do |record|
          Rails.logger.debug "#{self.class.name} recording first login for #{@uid}"
          record.preferred_name = @override_name
          record.first_login_at = @first_login_at
        end
        if @calcentral_user_data.preferred_name != @override_name
          @calcentral_user_data.update_attribute(:preferred_name, @override_name)
        end
      end
    }
    Calcentral::USER_CACHE_EXPIRATION.notify @uid
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
    google_mail = Oauth2Data.get_google_email(@uid)
    canvas_mail = Oauth2Data.get_canvas_email(@uid)
    is_google_reminder_dismissed = Oauth2Data.is_google_reminder_dismissed(@uid)
    is_google_reminder_dismissed = is_google_reminder_dismissed && is_google_reminder_dismissed.present?
    campus_courses_proxy = CampusUserCoursesProxy.new({:user_id => @uid})
    has_student_history = campus_courses_proxy.has_student_history?
    has_instructor_history = campus_courses_proxy.has_instructor_history?
    {
      :is_admin => UserAuth.is_superuser?(@uid),
      :first_login_at => @first_login_at,
      :first_name => @first_name,
      :full_name => @first_name + ' ' + @last_name,
      :is_google_reminder_dismissed => is_google_reminder_dismissed,
      :has_canvas_account => CanvasProxy.has_account?(@uid),
      :has_google_access_token => GoogleProxy.access_granted?(@uid),
      :google_email => google_mail,
      :canvas_email => canvas_mail,
      :last_name => @last_name,
      :preferred_name => self.preferred_name,
      :roles => @campus_attributes[:roles],
      :student_info => {
        :california_residency => @campus_attributes[:california_residency],
        :reg_status => @campus_attributes[:reg_status],
        :reg_block => get_reg_blocks,
        :has_student_history => has_student_history,
        :has_instructor_history => has_instructor_history,
        :has_academics_tab => @campus_attributes && @campus_attributes[:roles] && (@campus_attributes[:roles][:student] ||
          @campus_attributes[:roles][:faculty] ||
          has_instructor_history ||
          has_student_history
        )
      },
      :uid => @uid
    }
  end

  def self.is_allowed_to_log_in?(uid)
    unless Settings.features.user_whitelist
      return true
    end
    if UserData.where(uid: uid).first.present?
      return true
    end
    if UserWhitelist.where(uid: uid).first.present?
      return true
    end
    if (info = CampusData.get_student_info(uid))
      Settings.user_whitelist.first_year_codes.each do |code|
        if code.term_yr == info["first_reg_term_yr"] && code.term_cd == info["first_reg_term_cd"]
          return true
        end
      end
    end
    if CanvasProxy.has_account?(uid)
      return true
    end
    if (info.try(:[], "ug_grad_flag") == "G" &&
      /STUDENT-STATUS-EXPIRED/.match(info["affiliations"]).nil? &&
      CampusData.is_previous_ugrad?(uid))
      return true
    end

    false
  end

  def get_reg_blocks
    blocks_feed = MyRegBlocks.new(@uid, original_uid: @original_uid).get_feed
    response = {
      available: blocks_feed.present? && blocks_feed[:available],
      needsAction: blocks_feed[:active_blocks].present?,
      active_blocks: blocks_feed[:active_blocks] ? blocks_feed[:active_blocks].length : 0
    }

    response
  end

end
