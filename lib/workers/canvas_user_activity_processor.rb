class CanvasUserActivityProcessor
  extend Calcentral::Cacheable
  include DatedFeed
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
    self.class.fetch_from_cache @uid do
      begin
        @canvas_classes = filter_classes(MyClasses.new(@uid).get_feed[:classes])
      rescue
        @canvas_classes = []
      end
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
        date = ([entry["created_at"], entry["updated_at"]].map! {|e| Time.zone.parse(e)}).max
        if date <= Time.zone.today.advance(days: -10)
          next
        end
        date = date.to_datetime
      rescue
        next
      end

      title = process_title entry
      # Filter out the entries that have an empty title attribute
      next if title.nil?

      formatted_entry = {}
      formatted_entry[:id] = "canvas_#{entry["id"]}"
      formatted_entry[:type] = process_type entry["type"]
      formatted_entry[:user_id] = @uid
      formatted_entry[:title] = title
      formatted_entry[:source] = process_source entry
      formatted_entry[:emitter] = "Canvas"
      formatted_entry[:color_class] = "canvas-class"
      formatted_entry[:url] = entry["html_url"]
      formatted_entry[:source_url] = entry["html_url"]
      formatted_entry[:summary] = process_message entry
      formatted_entry[:date] = format_date date

      feed << formatted_entry
    end
    feed
  end

  def process_type(type)
    type.downcase!

    # The translator hash
    type_translator = {
      announcement: "announcement",
      collaboration: "discussion",
      collectionitem: "assignment",
      message: "assignment",
      discussiontopic: "discussion",
      submission: "grade_posting",
      webconference: "webconference"
    }
    # Find the type we need to return in the hash
    return_type = type_translator[type.to_sym]

    # Return type will be nil if it wasn't found
    # we should set a default and log a warning message
    if return_type.nil?
      return_type = 'assignment'
      Rails.logger.warn "#{self.class.name} processor tried to process the type: '#{type}' with the #{__method__} method but didn't find anyting."
    end

    return_type
  end

  def process_title(entry)
    if entry["type"] == "Message"
      title_and_summary = split_title_and_summary entry["title"]
      title_and_summary ||= ["New/Updated Conversation"] if entry["type"] == "Conversation"
      title_and_summary[0]
    else
      entry["title"]
    end
  end

  def split_title_and_summary(title)
    title.split(/( - |: )/, 3) unless title.blank?
  end

  def process_message(entry)
    message_partial = Nokogiri::HTML(entry["message"])
    message_partial = message_partial.xpath("//text()").to_s.gsub(/\s+/, " ").strip
    if entry["type"] == "Message"
      title_and_summary = split_title_and_summary entry["title"]
      message = title_and_summary[2] if title_and_summary.size > 2
      message ||= ''
      message += " - #{message_partial}"
      message
    else
      message_partial
    end
  end

  def filter_classes(classes = [])
    classes.select! { |entry| entry[:emitter] == "Canvas"}
    classes_hash = Hash[*classes.map { |entry| [Integer(entry[:id], 10), entry]}.flatten]
  end

  def process_source(entry)
    if (!entry["course_id"].blank? && !@canvas_classes.blank? &&
        @canvas_classes[entry["course_id"]])
      source = @canvas_classes[entry["course_id"]][:course_code]
    end
    source ||= "Canvas"
    source
  end

  def remove_dismissed_notifications!
    # TODO: Look against db for notifications that have been marked read
    @processed_feed
  end
end