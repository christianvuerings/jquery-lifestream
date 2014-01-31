class BaseProxy
  extend Calcentral::Cacheable
  include ClassLogger

  attr_accessor :fake, :settings

  def initialize(settings, options = {})
    @settings = settings
    @fake = (options[:fake] != nil) ? options[:fake] : @settings.fake
    @uid = options[:user_id]
  end

  def instance_cache_key
    self.class.key @uid
  end

  def safe_request
    begin
      yield
    rescue Calcentral::ProxyException => e
      log_message = e.log_message
      if e.wrapped_exception
        log_message += " #{e.wrapped_exception.class} #{e.wrapped_exception.message}."
      end
      log_message += " Associated cache key: #{e.cache_key}"
      logger.error log_message
      # TODO schedule a job to asynchronously delete cache_key 1000ms from now (tunable).
      return e.response
    end
  end

  # by default, all merged models will prevent act as users to read their
  # data without the enable_for_act_as mix-in.
  def self.allow_pseudo_user?
    false
  end

  def lookup_student_id
    student = CampusData.get_person_attributes @uid
    student.try(:[], "student_id")
  end

end
