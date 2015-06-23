module CampusOracle
  class UserAttributes < BaseProxy
    include Berkeley::UserRoles
    include Cache::UserCacheExpiry

    def initialize(options = {})
      super(Settings.sakai_proxy, options)
    end

    def get_feed
      # Because this data structure is used by multiple top-level feeds, it's essential
      # that it be cached efficiently.
      self.class.fetch_from_cache @uid do
        get_feed_internal
      end
    end

    # TODO Eliminate mix of string keys and symbol keys.
    def get_feed_internal
      result = CampusOracle::Queries.get_person_attributes(@uid)
      if result
        result[:education_level] = educ_level_translator.translate result['educ_level']
        result[:roles] = roles_from_campus_row result
        result.merge! Berkeley::SpecialRegistrationProgram.attributes_from_code(result['reg_special_pgm_cd'])

        if term_transition?
          result[:california_residency] = nil
          result[:reg_status] = result['reg_status_cd'] ? {transitionTerm: true} : reg_status_translator.translate_for_feed(nil)
        else
          result[:california_residency] = cal_residency_translator.translate result['cal_residency_flag']
          result[:reg_status] = reg_status_translator.translate_for_feed result['reg_status_cd']
        end

        result
      else
        {}
      end
    end

    # TODO These translation classes should be relocated and implemented as functional modules.
    def reg_status_translator
      @reg_status_translator ||= Notifications::RegStatusTranslator.new
    end
    def educ_level_translator
      @educ_level_translator ||= Notifications::EducLevelTranslator.new
    end
    def cal_residency_translator
      @cal_residency_translator ||= Notifications::CalResidencyTranslator.new
    end

    def is_staff_or_faculty?
      if feed = get_feed
        return true if get_feed[:roles] && (get_feed[:roles][:faculty] || get_feed[:roles][:staff])
      end
      false
    end

    def term_transition?
      Berkeley::Terms.fetch.current.sis_term_status != 'CT'
    end

  end
end
