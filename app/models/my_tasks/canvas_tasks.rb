module MyTasks
  class CanvasTasks
    include MyTasks::TasksModule, SafeJsonParser

    def initialize(uid, starting_date)
      @uid = uid
      @starting_date = starting_date
      @now_time = Time.zone.now
    end

    def fetch_tasks
      # Track assignment IDs to filter duplicates.
      tasks = []
      assignments = Set.new
      user_courses = Canvas::UserCourses.new(user_id: @uid).courses
      course_id_to_code_map = {}
      user_courses.each do |course|
        course_id_to_code_map[course["id"]] = course["course_code"]
      end
      fetch_canvas_todo!(Canvas::Todo.new(:user_id => @uid), tasks, assignments, course_id_to_code_map)
      fetch_canvas_upcoming_events!(Canvas::UpcomingEvents.new(:user_id => @uid), tasks, assignments, course_id_to_code_map)
      tasks
    end

    private

    def fetch_canvas_todo!(canvas_proxy, tasks, assignments, course_id_to_code_map)
      response = canvas_proxy.todo
      if response && (response.status == 200)
        results = safe_json response.body
        if results
          Rails.logger.info "#{self.class.name} Sorting Canvas todo feed into buckets with starting_date #{@starting_date}; #{results}"
          results.each do |result|
            if (result["assignment"] != nil) && new_assignment?(result["assignment"], assignments)
              # Skip a teacher's "overdue for grading" assignments since they don't call for a red alert.
              if 'grading' != result['type']
                formatted_entry = {
                  "type" => "assignment",
                  "title" => result["assignment"]["name"],
                  "emitter" => Canvas::Proxy::APP_NAME,
                  "linkUrl" => result["assignment"]["html_url"],
                  "sourceUrl" => result["assignment"]["html_url"],
                  "status" => "inprogress"
                }
                if result["assignment"]["description"] != ""
                  formatted_entry["notes"] = ActionView::Base.full_sanitizer.sanitize(result["assignment"]["description"])
                end
                due_date = convert_date(result["assignment"]["due_at"])
                format_date_into_entry!(due_date, formatted_entry, "dueDate")
                bucket = determine_bucket(due_date, formatted_entry, @now_time, @starting_date)
                formatted_entry["bucket"] = bucket

                if course_id_to_code_map
                  formatted_entry["course_code"] = course_id_to_code_map[result["course_id"]]
                end

                # All scheduled assignments come back from Canvas with a timestamp, even if none selected. Ferret out untimed assignments.
                if due_date
                  if due_date.hour == 0 && due_date.minute == 0 && due_date.second == 0
                    formatted_entry["dueDate"]["hasTime"] = false
                  else
                    formatted_entry["dueDate"]["hasTime"] = true
                  end
                end

                Rails.logger.debug "#{self.class.name} Putting Canvas todo with due_date #{formatted_entry["due_date"]} in #{bucket} bucket: #{formatted_entry}"
                tasks.push(formatted_entry)
              end
            end
          end
        end
      end
    end

    def fetch_canvas_upcoming_events!(canvas_proxy, tasks, assignments, course_id_to_code_map)
      response = canvas_proxy.upcoming_events
      if response && (response.status == 200)
        results = safe_json response.body
        if results
          Rails.logger.info "#{self.class.name} Sorting Canvas upcoming_events feed into buckets with starting_date #{@starting_date}"
          results.each do |result|
            type = result['assignment'] ? 'assignment' : 'event'
            Rails.logger.debug "Upcoming event = #{result["html_url"]}, type = #{type}"
            # Skip calendar events which are not associated with assignments.
            if (type == "assignment") && new_assignment?(result, assignments)
              # Skip assignments shown to graders (as opposed to students).
              if result['assignment']['needs_grading_count'].nil?
                formatted_entry = {
                  "type" => type,
                  "title" => result["title"],
                  "emitter" => Canvas::Proxy::APP_NAME,
                  "linkUrl" => result["html_url"],
                  "sourceUrl" => result["html_url"],
                  "status" => "inprogress"
                }
                due_date = convert_date(result["start_at"])
                format_date_into_entry!(due_date, formatted_entry, "dueDate")
                bucket = determine_bucket(due_date, formatted_entry, @now_time, @starting_date)
                formatted_entry["bucket"] = bucket

                if course_id_to_code_map
                  formatted_entry["course_code"] = course_id_to_code_map[result["assignment"]["course_id"]]
                end

                Rails.logger.debug "#{self.class.name} Putting Canvas upcoming_events event with dueDate #{formatted_entry["dueDate"]} in #{bucket} bucket: #{formatted_entry}"
                tasks.push(formatted_entry)
              end
            end
          end
        end
      end
    end

    def new_assignment?(assignment, assignments)
      id = assignment["html_url"]
      assignments.add?(id)
    end
  end
end
