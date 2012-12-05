class MyTasks
  include ActiveAttr::Model

  def initialize(uid, starting_date=Date.today.to_time_in_current_zone)
    @uid = uid
    #To avoid issues with tz, use time or DateTime instead of Date (http://www.elabs.se/blog/36-working-with-time-zones-in-ruby-on-rails)
    @starting_date = starting_date
    @buckets = {
        "overdue" => {"title" => "Overdue", "tasks" => []},
        "due_today" => {"title" => "Due Today", "tasks" => []},
        "due_this_week" => {"title" => "Due This Week", "tasks" => []},
        "due_next_week" => {"title" => "Due Next Week", "tasks" => []},
        "unscheduled" => {"title" => "Unscheduled", "tasks" => []}
    }
  end

  def get_feed
    Rails.cache.fetch(self.class.cache_key(@uid)) do
      fetch_google_tasks
      fetch_canvas_tasks
      my_tasks = {
          "sections" => [@buckets["overdue"], @buckets["due_today"], @buckets["due_this_week"], @buckets["due_next_week"], @buckets["unscheduled"]]
      }
      logger.debug "#{self.class.name} get_feed is #{my_tasks.inspect}"
      my_tasks
    end
  end

  def self.cache_key(uid)
    key = "user/#{uid}/#{self.name}"
    logger.debug "#{self.class.name} cache_key will be #{key}"
    key
  end

  def self.expire(uid)
    Rails.cache.delete(self.cache_key(uid), :force => true)
  end

  private

  def fetch_google_tasks
    if GoogleProxy.access_granted?(@uid)
      google_proxy = GoogleProxy.new(user_id: @uid)

      google_tasks_results = google_proxy.tasks_list
      logger.info "#{self.class.name} Sorting Google tasks into buckets with starting_date #{@starting_date}"
      google_tasks_results.each do |response_page|
        next unless response_page.response.status == 200

        response_page.data["items"].each do |entry|
          next if entry["title"].blank?
          formatted_entry = {
              "type" => "task",
              "title" => entry["title"] || "",
              "emitter" => "Google Tasks",
              "link_url" => "https://mail.google.com/tasks/canvas?pli=1",
              "source_url" => entry["selfLink"] || "",
              "class" => "class2"
          }

          status = "needs_action" if entry["status"] == "needsAction"
          status ||= "completed"
          formatted_entry["status"] = status
          # Google task dates have misleading datetime accuracy. There is no way to record a specific due time
          # for tasks (through the UI), thus the reported time+tz is always 00:00:00+0000. Stripping off the false
          # accuracy so the application will apply the proper timezone when needed.
          due_date = Date.parse(entry["due"].to_s) unless entry["due"].blank?
          convert_due_date(due_date, formatted_entry)
          bucket = determine_bucket(due_date, status, formatted_entry)
          logger.info "#{self.class.name} Putting Google task with due_date #{formatted_entry["due_date"]} in #{bucket} bucket: #{formatted_entry}"
          @buckets[bucket]["tasks"].push(formatted_entry)
        end
      end
    end
  end

  def fetch_canvas_tasks
    if CanvasProxy.access_granted?(@uid)
      canvas_proxy = CanvasProxy.new(:user_id => @uid)
      response = canvas_proxy.coming_up
      if response.status == 200
        results = JSON.parse response.body
        logger.info "#{self.class.name} Sorting Canvas tasks into buckets with starting_date #{@starting_date}"
        results.each do |result|
          formatted_entry = {
              "type" => result["type"].downcase,
              "title" => result["title"],
              "emitter" => CanvasProxy::APP_ID,
              "link_url" => result["html_url"],
              "source_url" => result["html_url"],
              "color_class" => "class1",
              "status" => "inprogress"
          }
          due_date = result["start_at"]
          convert_due_date(due_date, formatted_entry)
          bucket = determine_bucket(due_date, "inprogress", formatted_entry)
          logger.info "#{self.class.name} Putting Canvas task with due_date #{formatted_entry["due_date"]} in #{bucket} bucket: #{formatted_entry}"
          @buckets[bucket]["tasks"].push(formatted_entry)
        end
      end
    end
  end

  def convert_due_date(due_date, formatted_entry)
    if !due_date.blank?
      due = due_date.to_time_in_current_zone.to_datetime if due_date.is_a?(Date)
      due ||= DateTime.parse(due_date.to_s)
      formatted_entry["due_date"] = {
          "epoch" => due.to_i,
          "datetime" => due.rfc3339(3),
          "date_string" => due.strftime("%-m/%d")
      }
    end
  end

  # Helps determine what section category for a task
  def determine_bucket(due_date, status, formatted_entry)
    bucket = "unscheduled"
    if !due_date.blank?
      due = due_date.to_time_in_current_zone if due_date.is_a?(Date)
      due ||= DateTime.parse(due_date.to_s)
      due = due.to_i
      @starting_date = @starting_date.to_time.in_time_zone.to_i unless @starting_date.is_a?(Time)
      today = @starting_date.to_i
      tomorrow = @starting_date.advance(:days => 1).to_i
      end_of_this_week = @starting_date.sunday.to_i

      if due < today
        bucket = "overdue"
      elsif due >= today && due < tomorrow
        bucket = "due_today"
      elsif due >= tomorrow && due < end_of_this_week
        bucket = "due_this_week"
      elsif due >= end_of_this_week
        bucket = "due_next_week"
      end

      logger.debug "#{self.class.name} In determine_bucket, @starting_date = #{@starting_date}, today = #{today}; formatted entry = #{formatted_entry}"
    end
    bucket
  end
end
