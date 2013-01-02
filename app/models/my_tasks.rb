class MyTasks < MyMergedModel

  def initialize(uid, starting_date=Date.today.to_time_in_current_zone)
    super(uid)
    #To avoid issues with tz, use time or DateTime instead of Date (http://www.elabs.se/blog/36-working-with-time-zones-in-ruby-on-rails)
    @starting_date = starting_date
    @response = {
      "tasks" => []
    }
  end

  def get_feed_internal
    fetch_google_tasks
    fetch_canvas_tasks
    # TODO sort the tasks by due_date.epoch
    logger.debug "#{self.class.name} get_feed is #{@response.inspect}"
    @response
  end

  def update_task(params, task_list_id="@default")
    validate_update_params params
    if params["emitter"] == "Google Tasks"
      if GoogleProxy.access_granted?(@uid)
        validate_google_params params
        body = format_google_update_task_request params
        google_proxy = GoogleProxy.new(user_id: @uid)
        logger.debug "#{self.class.name} update_task, sending to Google (task_list_id, task_id, body):
          {#{task_list_id}, #{params["id"]}, #{body.inspect}}"
        response = google_proxy.update_task(task_list_id, params["id"], body)
        if (response.response.status == 200)
          expire_cache
          format_google_task_response response.data
        else
          logger.info "Errors in proxy response: #{response.inspect}"
          {}
        end
      else
        {}
      end
    end
  end

  def insert_task(params, task_list_id="@default")
    if params["emitter"] == "Google Tasks"
      if GoogleProxy.access_granted?(@uid)
        body = format_google_insert_task_request params
        google_proxy = GoogleProxy.new(user_id: @uid)
        logger.debug "#{self.class.name} insert_task, sending to Google (task_list_id, body):
          {#{task_list_id}, #{body.inspect}}"
        response = google_proxy.insert_task(task_list_id, body)
        if (response.response.status == 200)
          expire_cache
          format_google_task_response response.data
        else
          logger.info "Errors in proxy response: #{response.inspect}"
          {}
        end
      else
        {}
      end
    end
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

          formatted_entry = format_google_task_response(entry)
          due_date = Date.parse(entry["due"].to_s) unless entry["due"].blank?
          bucket = determine_bucket(due_date, formatted_entry)
          formatted_entry["bucket"] = bucket
          logger.info "#{self.class.name} Putting Google task with due_date #{formatted_entry["due_date"]} in #{bucket} bucket: #{formatted_entry}"
          @response["tasks"].push(formatted_entry)
        end
      end
    end
  end

  def format_google_task_response(entry)
    formatted_entry = {
        "type" => "task",
        "title" => entry["title"] || "",
        "emitter" => "Google Tasks",
        "link_url" => "https://mail.google.com/tasks/canvas?pli=1",
        "id" => entry["id"],
        "source_url" => entry["selfLink"] || "",
        "color_class" => "google-task"
    }

    if entry["notes"]
      formatted_entry["note"] = entry["notes"]
    end

    status = "needs_action" if entry["status"] == "needsAction"
    status ||= "completed"
    formatted_entry["status"] = status
    # Google task dates have misleading datetime accuracy. There is no way to record a specific due time
    # for tasks (through the UI), thus the reported time+tz is always 00:00:00+0000. Stripping off the false
    # accuracy so the application will apply the proper timezone when needed.
    due_date = Date.parse(entry["due"].to_s) unless entry["due"].blank?
    format_date_into_entry!(convert_due_date(due_date), formatted_entry)
    logger.debug "#{self.class.name}: Formatted body response from google proxy - #{formatted_entry.inspect}"
    formatted_entry
  end

  def format_google_update_task_request(entry)
    formatted_entry = {"id" => entry["id"]}
    formatted_entry["status"] = "needsAction" if entry["status"] == "needs_action"
    formatted_entry["status"] ||= "completed"
    logger.debug "Formatted body entry for google proxy update_task: #{formatted_entry.inspect}"
    formatted_entry
  end

  def format_google_insert_task_request(entry)
    formatted_entry = {"title" => entry["title"]}
    logger.debug "Formatted body entry for google proxy update_task: #{formatted_entry.inspect}"
    formatted_entry
  end

  def fetch_canvas_tasks
    if CanvasProxy.access_granted?(@uid)
      canvas_proxy = CanvasProxy.new(:user_id => @uid)
      fetch_canvas_coming_up canvas_proxy
      fetch_canvas_todo canvas_proxy
    end
  end

  def fetch_canvas_coming_up(canvas_proxy)
    response = canvas_proxy.coming_up
    if response.status == 200
      results = JSON.parse response.body
      logger.info "#{self.class.name} Sorting Canvas coming_up feed into buckets with starting_date #{@starting_date}"
      results.each do |result|
        formatted_entry = {
            "type" => result["type"].downcase,
            "title" => result["title"],
            "emitter" => CanvasProxy::APP_ID,
            "link_url" => result["html_url"],
            "source_url" => result["html_url"],
            "color_class" => "canvas-class",
            "status" => "inprogress"
        }
        due_date = result["start_at"]
        format_date_into_entry!(convert_due_date(due_date), formatted_entry)
        bucket = determine_bucket(due_date, formatted_entry)
        formatted_entry["bucket"] = bucket
        logger.info "#{self.class.name} Putting Canvas coming_up event with due_date #{formatted_entry["due_date"]} in #{bucket} bucket: #{formatted_entry}"
        @response["tasks"].push(formatted_entry)
      end
    end
  end

  def fetch_canvas_todo(canvas_proxy)
    response = canvas_proxy.todo
    if response.status == 200
      results = JSON.parse response.body
      logger.info "#{self.class.name} Sorting Canvas todo feed into buckets with starting_date #{@starting_date}; #{results}"
      results.each do |result|
        if result["assignment"] != nil
          due_date = result["assignment"]["due_at"]
          due_date = convert_due_date(due_date)
          if due_date.to_i < @starting_date.to_i
            formatted_entry = {
                "type" => "assignment",
                "title" => result["assignment"]["name"],
                "emitter" => CanvasProxy::APP_ID,
                "link_url" => result["assignment"]["html_url"],
                "source_url" => result["assignment"]["html_url"],
                "color_class" => "canvas-class",
                "status" => "inprogress"
            }
            format_date_into_entry!(due_date, formatted_entry)
            bucket = determine_bucket(due_date, formatted_entry)
            formatted_entry["bucket"] = bucket
            logger.info "#{self.class.name} Putting Canvas todo with due_date #{formatted_entry["due_date"]} in #{bucket} bucket: #{formatted_entry}"
            @response["tasks"].push(formatted_entry)
          else
            logger.info "#{self.class.name} Skipping Canvas todo with due_date that's in the future: #{result}'"
          end
        end
      end
    end
  end

  def convert_due_date(due_date)
    if due_date.blank?
      nil
    elsif due_date.is_a?(Date)
      due_date.to_time_in_current_zone.to_datetime
    else
      DateTime.parse(due_date.to_s)
    end
  end

  def format_date_into_entry!(due, formatted_entry)
    if !due.blank?
      formatted_entry["due_date"] = {
          "epoch" => due.to_i,
          "datetime" => due.rfc3339(3),
          "date_string" => due.strftime("%-m/%d")
      }
    end
  end

  # Helps determine what section category for a task
  def determine_bucket(due_date, formatted_entry)
    bucket = "Unscheduled"
    if !due_date.blank?
      due = due_date.to_time_in_current_zone if due_date.is_a?(Date)
      due ||= DateTime.parse(due_date.to_s)
      due = due.to_i
      @starting_date = @starting_date.to_time.in_time_zone.to_i unless @starting_date.is_a?(Time)
      today = @starting_date.to_i
      tomorrow = @starting_date.advance(:days => 1).to_i
      end_of_this_week = @starting_date.sunday.to_i

      if due < today
        bucket = "Overdue"
      elsif due >= today && due < tomorrow
        bucket = "Due Today"
      elsif due >= tomorrow && due < end_of_this_week
        bucket = "Due This Week"
      elsif due >= end_of_this_week
        bucket = "Due Next Week"
      end

      logger.debug "#{self.class.name} In determine_bucket, @starting_date = #{@starting_date}, today = #{today}; formatted entry = #{formatted_entry}"
    end
    bucket
  end

  def includes_whitelist_values?(whitelist_array=[])
    Proc.new { |status_arg| !status_arg.blank? && whitelist_array.include?(status_arg) }
  end

  # Validate params does two different type of validations. 1) Required - existance of key validation. A key specified in
  # filter_keys must exist in initial_hash, or else the Missing parameter argumentError is thrown. 2) Optional - Proc function
  # validation on initial_hash values. If a Proc is provided as a value for a filter_key, the proc will be executed and expect
  # a boolean result of whether or not validation passed. Anything other than a Proc is treated as noop.
  def validate_params(initial_hash={}, filters={})
    filter_keys = filters.keys
    params_to_check = initial_hash.select { |key, value| filter_keys.include? key }
    raise ArgumentError, "Missing parameter(s). Required: #{filter_keys}" if params_to_check.length != filter_keys.length
    filters.keep_if { |key, value| value.is_a?(Proc) }
    filters.each do |filter_key, filter_proc|
      logger.debug "Validating params for #{filter_key}"
      if !(filter_proc.call(params_to_check[filter_key]))
        raise ArgumentError, "Invalid parameter for: #{filter_key}"
      end
    end
  end

  def validate_update_params(params)
    filters = {
        "type" => Proc.new { |arg| !arg.blank? && arg.is_a?(String) },
        "emitter" => includes_whitelist_values?(["Canvas", "Google Tasks"]),
        "status" => includes_whitelist_values?(%w(needs_action completed))
    }
    validate_params(params, filters)
  end

  def validate_google_params(params)
    # just need to make sure ID is non-blank, general_params caught the rest.
    google_filters = {"id" => "noop, not a Proc type"}
    validate_params(params, google_filters)
  end
end
