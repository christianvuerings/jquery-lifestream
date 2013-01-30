# The handler will be responsible for kicking off the worker to consume the canvas feed
# and the processor to make sense of the feed. The handler for now will probably be a
# temporary stub until we get a proper supervisor in place.
class CanvasUserActivityHandler

  def initialize(options)
    @worker = CanvasUserActivityWorker.new(options)
    @processor = CanvasUserActivityProcessor.new(options)
    @processor_future = nil
  end

  # Will kick off the worker and processor to get feed data but return the processor
  # response as a future object to not block the thread calling this.
  def get_feed
    begin
      activity_feed_future = @worker.future.fetch_user_activity
      @processor_future = @processor.future.process(activity_feed_future)
    rescue Exception => e
      Rails.logger.info "#{self.class.name} with exception: #{e.message}"
    end
  end

  def get_feed_results
    get_feed if @processor_future == nil
    begin
      @processor_future.value
    rescue Exception => e
      Rails.logger.info "#{self.class.name} with exception: #{e.message}"
      nil
    end
  end

  def finalize
    # One of the things that will eventually be handled by the supervisor
    [@worker, @processor].each do |some_actor|
      begin
        some_actor.terminate
      rescue Celluloid::DeadActorError
      end
    end
  end
end