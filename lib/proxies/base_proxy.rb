require 'lib/cacheable.rb'

class BaseProxy
  extend Calcentral::Cacheable

  attr_accessor :fake, :settings

  def initialize(settings, options = {})
    @settings = settings
    @fake = (options[:fake] != nil) ? options[:fake] : @settings.fake
  end

end