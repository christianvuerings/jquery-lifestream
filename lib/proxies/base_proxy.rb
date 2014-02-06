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
    # returns the full cache key (incl user or global prefix) used by this proxy instance.
    self.class.key @uid
  end

  def safe_request(user_message_on_exception = "An unknown server error occurred.", return_nil_on_generic_error = false)
    begin
      yield
    rescue Exception => e
      if e.is_a?(Calcentral::ProxyException)
        log_message = e.log_message
        response = e.response
        if e.wrapped_exception
          log_message += " #{e.wrapped_exception.class} #{e.wrapped_exception.message}."
        end
      else
        log_message = " #{e.class} #{e.message}"
        if return_nil_on_generic_error
          response = nil
        else
          response = {
            :body => user_message_on_exception,
            :status_code => 503
          }
        end
      end
      log_message += " Associated cache key: #{instance_cache_key}"

      if e.is_a?(Calcentral::ProxyError)
        logger.error log_message
      else
        logger.debug log_message
      end

      DelayedCacheCleaner.queue instance_cache_key

      return response
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
