module MyTasks
  class CanvasTasks
    include MyTasks::TasksModule
    attr_accessor :future_count

    def initialize(uid, starting_date)
      @uid = uid
      @starting_date = starting_date
      @now_time = Time.zone.now
      @future_count = 0
    end

    def fetch_tasks
      # Track assignment IDs to filter duplicates.
      tasks = []
      assignments = Set.new
      fetch_canvas_todo!(CanvasTodoProxy.new(:user_id => @uid), tasks, assignments)
      fetch_canvas_upcoming_events!(CanvasUpcomingEventsProxy.new(:user_id => @uid), tasks, assignments)
      tasks
    end

    private

    def fetch_canvas_todo!(canvas_proxy, tasks, assignments)
      response = canvas_proxy.todo
      if response && (response.status == 200)
        begin
          results = JSON.parse response.body
        rescue JSON::ParserError
          Rails.logger.error "#{self.class.name} Got invalid json in todo feed: #{response.body}"
        end
        if results
          Rails.logger.info "#{self.class.name} Sorting Canvas todo feed into buckets with starting_date #{@starting_date}; #{results}"
          results.each do |result|
            if (result["assignment"] != nil) && new_assignment?(result["assignment"], assignments)
              # Skip a teacher's "overdue for grading" assignments since they don't call for a red alert.
              if 'grading' != result['type']
                formatted_entry = {
                  "type" => "assignment",
                  "title" => result["assignment"]["name"],
                  "emitter" => CanvasProxy::APP_NAME,
                  "link_url" => result["assignment"]["html_url"],
                  "source_url" => result["assignment"]["html_url"],
                  "status" => "inprogress"
                }
                if result["assignment"]["description"] != ""
                  formatted_entry["notes"] = ActionView::Base.full_sanitizer.sanitize(result["assignment"]["description"])
                end
                due_date = convert_date(result["assignment"]["due_at"])
                format_date_into_entry!(due_date, formatted_entry, "due_date")
                bucket = determine_bucket(due_date, formatted_entry, @now_time, @starting_date)
                formatted_entry["bucket"] = bucket

                # All scheduled assignments come back from Canvas with a timestamp, even if none selected. Ferret out untimed assignments.
                if due_date
                  if due_date.hour == 0 && due_date.minute == 0 && due_date.second == 0
                    formatted_entry["due_date"]["has_time"] = false
                  else
                    formatted_entry["due_date"]["has_time"] = true
                  end
                end

                Rails.logger.debug "#{self.class.name} Putting Canvas todo with due_date #{formatted_entry["due_date"]} in #{bucket} bucket: #{formatted_entry}"
                @future_count += push_if_feed_has_room!(formatted_entry, tasks, @future_count)
              end
            end
          end
        end
      end
    end

    def fetch_canvas_upcoming_events!(canvas_proxy, tasks, assignments)
      response = canvas_proxy.upcoming_events
      if response && (response.status == 200)
        begin
          results = JSON.parse response.body
        rescue JSON::ParserError
          Rails.logger.error "#{self.class.name} Got invalid json in events feed: #{response.body}"
        end
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
                  "emitter" => CanvasProxy::APP_NAME,
                  "link_url" => result["html_url"],
                  "source_url" => result["html_url"],
                  "status" => "inprogress"
                }
                due_date = convert_date(result["start_at"])
                format_date_into_entry!(due_date, formatted_entry, "due_date")
                bucket = determine_bucket(due_date, formatted_entry, @now_time, @starting_date)
                formatted_entry["bucket"] = bucket
                Rails.logger.debug "#{self.class.name} Putting Canvas upcoming_events event with due_date #{formatted_entry["due_date"]} in #{bucket} bucket: #{formatted_entry}"
                @future_count += push_if_feed_has_room!(formatted_entry, tasks, @future_count)
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
