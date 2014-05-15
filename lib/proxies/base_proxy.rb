class BaseProxy
  extend Cache::Cacheable
  include ClassLogger

  attr_accessor :fake, :settings

  def initialize(settings, options = {})
    @settings = settings
    @fake = (options[:fake] != nil) ? options[:fake] : @settings.fake
    @uid = options[:user_id]
  end

  # by default, all merged models will prevent act as users to read their
  # data without the enable_for_act_as mix-in.
  def self.allow_pseudo_user?
    false
  end

  def lookup_student_id
    student = CampusOracle::UserAttributes.new(user_id: @uid).get_feed
    student.try(:[], "student_id")
  end

end
