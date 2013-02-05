class CanvasUserActivityProcessor
  extend Calcentral::Cacheable
  include Celluloid

  def initialize(options)
    Rails.logger.info "New #{self.class.name} processor with #{options}"
    @uid = options[:user_id]
    @processed_feed = []
  end

  def process(worker_future)
    # Potential crash somewhere up the pipe if the feed was nil
    raw_feed = worker_future.value
    return if raw_feed.nil?
    # Translate the feed
    Rails.cache.fetch(
      self.class.cache_key(@uid),
      :expires_in => Settings.cache.api_expires_in,
      :race_condition_ttl => 2.seconds
    ) do
      @processed_feed = internal_process_feed(raw_feed)
      remove_dismissed_notifications!
    end
    @processed_feed
  end

  def finalize
    Rails.logger.info "#{self.class.name} is going away"
  end

  private
  def internal_process_feed(raw_feed)
    feed = []
    raw_feed.each do |entry|
      begin
        date = [DateTime.parse(entry["created_at"]), DateTime.parse(entry["updated_at"])].max
      rescue
        next
      end
      formatted_entry = {}
      formatted_entry[:id] = "canvas_#{entry["id"]}"
      formatted_entry[:type] = entry["type"]
      formatted_entry[:user_id] = @uid
      if entry["type"] == "Message"
        title_and_summary = entry["title"].split(/( - |: )/, 3) unless entry["title"].blank?
        title_and_summary ||= ["New/Updated Conversation"] if entry["type"] == "Conversation"
        formatted_entry[:title] = title_and_summary[0]
      else
        formatted_entry[:title] = entry["title"]
      end
      formatted_entry[:source] = "Canvas"
      formatted_entry[:emitter] = "Canvas"
      formatted_entry[:color_class] = "canvas-class"
      formatted_entry[:url] = entry["html_url"]
      formatted_entry[:source_url] = entry["html_url"]
      message_partial = Nokogiri::HTML(entry["message"])
      message_partial = message_partial.xpath("//text()").to_s.gsub(/\s+/, " ").strip
      if entry["type"] == "Message"
        formatted_entry[:summary] = title_and_summary[2] if title_and_summary.size > 2
        formatted_entry[:summary] ||= ''
        formatted_entry[:summary] += " - #{message_partial}"
      else
        formatted_entry[:summary] = message_partial
      end
      formatted_entry[:date] = {
        :epoch => date.to_i,
        :datetime => date.rfc3339(3),
        :date_string => date.strftime("%-m/%d")
      }
      feed << formatted_entry
    end
    feed
  end

  def remove_dismissed_notifications!
    # TODO: Look against db for notifications that have been marked read
    @processed_feed
  end
end