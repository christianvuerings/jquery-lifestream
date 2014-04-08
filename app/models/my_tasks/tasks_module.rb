module MyTasks
  module TasksModule
    include DatedFeed
    include MyTasks::ParamValidator

    def self.included(klass)
      klass.extend Cache::Cacheable
    end

    def fetch_tasks
      []
    end

    def update_task(task, task_list_id="@default")
      {}
    end

    def insert_task(task, task_list_id="@default")
      {}
    end

    def clear_completed_tasks(task_list_id="@default")
      {tasksCleared: false}
    end

    def delete_task(task_list_id, task_id)
      {task_deleted: false}
    end

    # Helps determine what section category for a task
    def determine_bucket(due_date, formatted_entry, now_time, starting_date)
      bucket = "Unscheduled"
      if !due_date.blank?
        tomorrow = starting_date.advance(:days => 1)

        if due_date.to_time.to_i < now_time.to_time.to_i
          bucket = "Overdue"
        elsif due_date.to_time.to_i >= now_time.to_time.to_i && due_date.to_time.to_i < tomorrow.to_time.to_i
          bucket = "Today"
        elsif due_date.to_time.to_i >= tomorrow.to_time.to_i
          bucket = "Future"
        end

        Rails.logger.debug "#{self.class.name} In determine_bucket, bucket = #{bucket}, due_date = #{due_date}, now_time = #{now_time}, tomorrow = #{tomorrow}; formatted entry = #{formatted_entry}"
      end
      bucket
    end

    def format_date_into_entry!(date, formatted_entry, field_name)
      if !date.blank?
        formatted_entry[field_name] = format_date(date).stringify_keys
      end
    end

    def convert_date(date)
      if date.blank?
        nil
      else
        DateTime.parse(date.to_s)
      end
    end

    def expire_cache(uid)
      self.class.expire uid
    end

    def push_if_feed_has_room!(formatted_entry, tasks_feed, future_count)
      # Future bucket has a limit of 10 tasks
      if formatted_entry["bucket"] == "Future"
        if future_count < 10
          tasks_feed.push(formatted_entry)
          return 1
        end
      else
        tasks_feed.push(formatted_entry)
      end
      0
    end
  end
end
