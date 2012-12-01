class MyTasks
  include ActiveAttr::Model

  def self.get_feed(uid, starting_date=Date.today, opts={})
    Rails.cache.fetch(self.cache_key(uid)) do
      my_tasks = {}
      buckets = {
        "due" => {"title" => "Due", "tasks" => []},
        "due_tomorrow" => {"title" => "Due Tomorrow", "tasks" => []},
        "upcoming" => {"title" => "Upcoming", "tasks" => []},
        "unscheduled" => {"title" => "Unscheduled", "tasks" => []}
      }

      if GoogleProxy.access_granted?(uid)
        google_proxy = GoogleProxy.new(user_id: uid)

        google_tasks_results = google_proxy.tasks_list(opts)
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
            due_date = entry["due"]
            if !due_date.blank?
              formatted_entry["due_date"] = {
                "epoch" => due_date.to_i,
                "datetime" => DateTime.parse(due_date.to_s).rfc3339(3),
                "date_string" => DateTime.parse(due_date.to_s).strftime("%-m/%d")
              }
            end

            bucket = determine_bucket(starting_date, due_date, status, formatted_entry)
            buckets[bucket]["tasks"].push(formatted_entry)
          end
        end
      end
      my_tasks["sections"] = [buckets["due"], buckets["due_tomorrow"], buckets["upcoming"], buckets["unscheduled"]]

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

  # Helps determine what section category for a task
  def self.determine_bucket(starting_date, due_date, status, formatted_entry)
    bucket = "unscheduled"
    today = starting_date.to_time.to_i
    tomorrow = (starting_date + 1).to_time.to_i
    day_after_tomorrow = (starting_date + 2).to_time.to_i

    if !due_date.blank? && (due_date.to_i < tomorrow)
      bucket = "due"
      formatted_entry["status"] = "overdue" if (status == "needs_action" && (due_date.to_i < today))
    elsif !due_date.blank? && (due_date.to_i >= tomorrow) && (due_date.to_i < day_after_tomorrow)
      bucket = "due_tomorrow"
    elsif !due_date.blank? && (due_date.to_i > day_after_tomorrow)
      bucket = "upcoming"
    end

    bucket
  end
end
