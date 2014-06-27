class BaseProxy
  extend Cache::Cacheable
  include ClassLogger

  attr_accessor :fake, :settings

  def initialize(settings, options = {})
    @settings = settings
    @fake = (options[:fake] != nil) ? options[:fake] : @settings.fake
    @uid = options[:user_id]
  end

  def lookup_student_id
    student = CampusOracle::UserAttributes.new(user_id: @uid).get_feed
    student.try(:[], "student_id")
  end

end
