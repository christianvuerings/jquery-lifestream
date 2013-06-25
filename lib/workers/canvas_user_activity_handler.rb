# The handler will be responsible for kicking off the worker to consume the canvas feed
# and the processor to make sense of the feed. The handler for now will probably be a
# temporary stub until we get a proper supervisor in place.
class CanvasUserActivityHandler

  def initialize(options)
    # More caution regarding Celluloid actors, only spawn when access is granted.
    @access_granted = CanvasProxy.access_granted?(options[:user_id])
    if (@access_granted)
      @worker = CanvasUserActivityWorker.new(options)
      @processor = CanvasUserActivityProcessor.new(options)
    end
    @processed_feed = nil
  end

  # Will kick off the worker and processor to get feed data but return the processor
  # response as a future object to not block the thread calling this.
  def get_feed
    return unless @access_granted
    begin
      raw_activity_feed = @worker.fetch_user_activity
      @processed_feed = @processor.process_feed(raw_activity_feed)
    rescue Exception => e
      Rails.logger.warn "#{self.class.name} with exception: #{e.message}"
    end
  end

  def get_feed_results
    return nil unless @access_granted
    get_feed if @processed_feed == nil
    begin
      @processed_feed
    rescue Exception => e
      Rails.logger.warn "#{self.class.name} with exception: #{e.message}"
      nil
    end
  end

end