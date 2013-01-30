class CanvasUserActivityWorker
  include Celluloid

  def initialize(options = {})
    Rails.logger.info "New #{self.class.name} worker with #{options}"
    @user_activity_feed = CanvasUserActivityProxy.new(options)
  end

  def fetch_user_activity
    response = @user_activity_feed.user_activity
    JSON.parse(response.body)
  end

  def finalize
    Rails.logger.info "#{self.class.name} is going away"
  end

end