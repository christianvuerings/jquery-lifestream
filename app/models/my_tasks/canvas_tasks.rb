module MyTasks
  class CanvasTasks
    include MyTasks::TasksModule, ClassLogger, HtmlSanitizer, SafeJsonParser

    def initialize(uid, starting_date)
      @uid = uid
      @starting_date = starting_date
      @now_time = Time.zone.now
    end

    def fetch_tasks
      # Track assignment IDs to filter duplicates.
      @assignments = Set.new
      @course_code_map = initialize_course_code_map
      tasks = []

      canvas_todo = Canvas::Todo.new(user_id: @uid).todo
      todo_results = collect_results(canvas_todo) { |result| format_todo result }
      tasks.concat todo_results.compact if todo_results

      canvas_upcoming_events = Canvas::UpcomingEvents.new(user_id: @uid).upcoming_events
      upcoming_event_results = collect_results(canvas_upcoming_events) { |result| format_upcoming_event result }
      tasks.concat upcoming_event_results.compact if upcoming_event_results

      tasks
    end

    private

    def collect_results(response)
      if response && (response.status == 200) && (results = safe_json response.body)
        logger.info "Sorting Canvas feed into buckets with starting_date #{@starting_date}; #{results}"
        results.collect do |result|
          if (formatted_entry = yield result)
            logger.debug "Adding Canvas task with dueDate: #{formatted_entry['dueDate']} in bucket '#{formatted_entry['bucket']}': #{formatted_entry}"
            formatted_entry
          end
        end
      end
    end

    def entry_from_result(result, title, course_id)
      {
        course_code: @course_code_map[course_id],
        emitter: Canvas::Proxy::APP_NAME,
        linkDescription: "View in #{Canvas::Proxy::APP_NAME}",
        linkUrl: result['html_url'],
        sourceUrl: result['html_url'],
        status: 'inprogress',
        title: title,
        type: 'assignment'
      }
    end

    def format_date_and_bucket(formatted_entry, date)
      format_date_into_entry!(date, formatted_entry, :dueDate)
      formatted_entry[:bucket] = determine_bucket(date, formatted_entry, @now_time, @starting_date)
    end

    def format_todo(result)
      logger.debug "Todo URL: #{result['html_url']}, is assignment: #{result['assignment'].present?}"
      if result['assignment'] && new_assignment?(result['assignment'])
        # Skip a teacher's "overdue for grading" assignments since they don't call for a red alert.
        if result['type'] != 'grading'
          formatted_entry = entry_from_result(result['assignment'], result['assignment']['name'], result['course_id'])
          formatted_entry[:notes] = sanitize_html(result['assignment']['description']) if result['assignment']['description'].present?

          due_date = convert_datetime_or_date result['assignment']['due_at']
          format_date_and_bucket(formatted_entry, due_date)
          # All scheduled assignments come back from Canvas with a timestamp, even if none selected. Ferret out untimed assignments.
          if due_date
            formatted_entry[:dueDate][:hasTime] = due_date.is_a?(DateTime)
          end

          if formatted_entry[:bucket] == 'Unscheduled'
            updated_date = convert_datetime_or_date(result['assignment']['updated_at'] || result['assignment']['created_at'])
            format_date_into_entry!(updated_date, formatted_entry, :updatedDate)
          end

          formatted_entry
        end
      end
    end

    def format_upcoming_event(result)
      logger.debug "Upcoming event URL: #{result['html_url']}, is assignment: #{result['assignment'].present?}"
      # Skip calendar events which are not associated with assignments.
      if result['assignment'] && new_assignment?(result)
        # Skip assignments shown to graders (as opposed to students).
        if result['assignment']['needs_grading_count'].nil?
          formatted_entry = entry_from_result(result, result['title'], result['assignment']['course_id'])
          format_date_and_bucket(formatted_entry, convert_datetime_or_date(result['start_at']))
          formatted_entry
        end
      end
    end

    def initialize_course_code_map
      user_courses = Canvas::UserCourses.new(user_id: @uid).courses
      user_courses.inject({}) { |map, course| map[course['id']] = course['course_code']; map }
    end

    def new_assignment?(assignment)
      id = assignment['html_url']
      @assignments.add? id
    end

  end
end
