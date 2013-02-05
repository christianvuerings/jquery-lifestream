require 'my_tasks/tasks_module'

class MyTasks::CanvasTasks
  include MyTasks::TasksModule

  def initialize(uid, starting_date)
    @uid = uid
    @starting_date = starting_date
    @now_time = DateTime.now
  end

  def fetch_tasks!(tasks)
    # Track assignment IDs to filter duplicates.
    assignments = Set.new
    fetch_canvas_coming_up!(CanvasComingUpProxy.new(:user_id => @uid), tasks, assignments)
    fetch_canvas_todo!(CanvasTodoProxy.new(:user_id => @uid), tasks, assignments)
  end

  private

  def fetch_canvas_coming_up!(canvas_proxy, tasks, assignments)
    response = canvas_proxy.coming_up
    if response && (response.status == 200)
      results = JSON.parse response.body
      Rails.logger.info "#{self.class.name} Sorting Canvas coming_up feed into buckets with starting_date #{@starting_date}"
      results.each do |result|
        if (result["type"] != "Assignment") || new_assignment?(result, assignments)
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
          due_date = convert_due_date(due_date)
          format_date_into_entry!(due_date, formatted_entry, "due_date")
          bucket = determine_bucket(due_date, formatted_entry, @now_time, @starting_date)
          formatted_entry["bucket"] = bucket
          Rails.logger.info "#{self.class.name} Putting Canvas coming_up event with due_date #{formatted_entry["due_date"]} in #{bucket} bucket: #{formatted_entry}"
          tasks.push(formatted_entry)
        end
      end
    end
  end

  def fetch_canvas_todo!(canvas_proxy, tasks, assignments)
    response = canvas_proxy.todo
    if response && (response.status == 200)
      results = JSON.parse response.body
      Rails.logger.info "#{self.class.name} Sorting Canvas todo feed into buckets with starting_date #{@starting_date}; #{results}"
      results.each do |result|
        if (result["assignment"] != nil) && new_assignment?(result["assignment"], assignments)
          due_date = result["assignment"]["due_at"]
          due_date = convert_due_date(due_date)
          formatted_entry = {
            "type" => "assignment",
            "title" => result["assignment"]["name"],
            "emitter" => CanvasProxy::APP_ID,
            "link_url" => result["assignment"]["html_url"],
            "source_url" => result["assignment"]["html_url"],
            "color_class" => "canvas-class",
            "status" => "inprogress"
          }
          format_date_into_entry!(due_date, formatted_entry, "due_date")
          bucket = determine_bucket(due_date, formatted_entry, @now_time, @starting_date)
          formatted_entry["bucket"] = bucket
          Rails.logger.info "#{self.class.name} Putting Canvas todo with due_date #{formatted_entry["due_date"]} in #{bucket} bucket: #{formatted_entry}"
          tasks.push(formatted_entry)
        end
      end
    end
  end

  def new_assignment?(assignment, assignments)
    id = assignment["html_url"]
    assignments.add?(id)
  end

end