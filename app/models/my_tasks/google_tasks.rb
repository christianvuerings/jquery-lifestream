require 'my_tasks/tasks_module'

class MyTasks::GoogleTasks
  include MyTasks::TasksModule

  def initialize(uid, starting_date)
    @uid = uid
    @starting_date = starting_date
    @now_time = DateTime.now
  end

  def fetch_tasks!(tasks)
    google_proxy = GoogleTasksListProxy.new(user_id: @uid)
    google_tasks_results = google_proxy.tasks_list
    Rails.logger.info "#{self.class.name} Sorting Google tasks into buckets with starting_date #{@starting_date}"
    google_tasks_results.each do |response_page|
      next unless response_page.response.status == 200
      response_page.data["items"].each do |entry|
        next if entry["title"].blank?
        formatted_entry = format_google_task_response(entry)
        tasks.push(formatted_entry) unless formatted_entry["bucket"] == "far future"
      end
    end
  end

  def update_task(params, task_list_id="@default")
    body = format_google_update_task_request params
    google_proxy = GoogleUpdateTaskProxy.new(user_id: @uid)
    Rails.logger.debug "#{self.class.name} update_task, sending to Google (task_list_id, task_id, body):
        {#{task_list_id}, #{params["id"]}, #{body.inspect}}"
    response = google_proxy.update_task(task_list_id, params["id"], body)
    formatted_response = {}
    if response.response.status == 200
      formatted_response = format_google_task_response response.data
    else
      Rails.logger.info "Errors in proxy response: #{response.inspect}"
    end
    formatted_response
  end

  def insert_task(params, task_list_id="@default")
    body = format_google_insert_task_request params
    google_proxy = GoogleInsertTaskProxy.new(user_id: @uid)
    Rails.logger.debug "#{self.class.name} insert_task, sending to Google (task_list_id, body):
          {#{task_list_id}, #{body.inspect}}"
    response = google_proxy.insert_task(task_list_id, body)
    formatted_response = {}
    if response.response.status == 200
      formatted_response = format_google_task_response response.data
    else
      Rails.logger.info "Errors in proxy response: #{response.inspect}"
    end
    formatted_response
  end

  private

  def format_google_insert_task_request(entry)
    formatted_entry = {}
    formatted_entry["title"] = entry["title"]
    if entry["due_date"] && !entry["due_date"].blank?
      formatted_entry["due"] = Date.strptime(entry["due_date"]).to_time_in_current_zone.to_datetime
    end
    formatted_entry["notes"] = entry["note"] if entry["note"]
    Rails.logger.debug "Formatted body entry for google proxy update_task: #{formatted_entry.inspect}"
    formatted_entry
  end

  def format_google_update_task_request(entry)
    validate_google_params entry
    formatted_entry = {"id" => entry["id"]}
    formatted_entry["status"] = "needsAction" if entry["status"] == "needs_action"
    formatted_entry["status"] ||= "completed"
    formatted_entry["due"] = entry["due_date"]["datetime"] if entry["due_date"] && entry["due_date"]["datetime"]
    Rails.logger.debug "Formatted body entry for google proxy update_task: #{formatted_entry.inspect}"
    formatted_entry
  end

  def format_google_task_response(entry)
    formatted_entry = {
      "type" => "task",
      "title" => entry["title"] || "",
      "emitter" => GoogleProxy::APP_ID,
      "link_url" => "https://mail.google.com/tasks/canvas?pli=1",
      "id" => entry["id"],
      "updated" => entry["updated"],
      "source_url" => entry["selfLink"] || "",
      "color_class" => "google-task"
    }

    # Some fields may or may not be present in Google feed
    if entry["notes"]
      formatted_entry["note"] = entry["notes"]
    end

    if entry["completed"]
      format_date_into_entry!(convert_due_date(entry["completed"]), formatted_entry, "completed_date")
    end

    status = "needs_action" if entry["status"] == "needsAction"
    status ||= "completed"
    formatted_entry["status"] = status
    due_date = entry["due"]
    unless due_date.nil?
      # Google task dates have misleading datetime accuracy. There is no way to record a specific due time
      # for tasks (through the UI), thus the reported time+tz is always 00:00:00+0000. Stripping off the false
      # accuracy so the application will apply the proper timezone when needed.
      due_date = Date.parse(due_date.to_s)
      # Tasks are not overdue until the end of the day.
      due_date = due_date.to_time_in_current_zone.to_datetime.advance(:hours => 23, :minutes => 59, :seconds => 59)
    end
    formatted_entry["bucket"] = determine_bucket(due_date, formatted_entry, @now_time, @starting_date)
    Rails.logger.info "#{self.class.name} Putting Google task with due_date #{formatted_entry["due_date"]} in #{formatted_entry["bucket"]} bucket: #{formatted_entry}"
    format_date_into_entry!(due_date, formatted_entry, "due_date")
    Rails.logger.debug "#{self.class.name}: Formatted body response from google proxy - #{formatted_entry.inspect}"
    formatted_entry
  end

  def validate_google_params(params)
    # just need to make sure ID is non-blank, general_params caught the rest.
    google_filters = {"id" => "noop, not a Proc type"}
    validate_params(params, google_filters)
  end

end