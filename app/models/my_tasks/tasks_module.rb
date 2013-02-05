require 'my_tasks/param_validator'

module MyTasks::TasksModule
  include MyTasks::ParamValidator

  def fetch_tasks!(tasks)
    tasks
  end

  def update_task(task, task_list_id="@default")
    {}
  end

  def insert_task(task, task_list_id="@default")
    {}
  end

  # Helps determine what section category for a task
  def determine_bucket(due_date, formatted_entry, now_time, starting_date)
    bucket = "Unscheduled"
    if !due_date.blank?
      due = due_date.to_i
      now = now_time.to_i
      tomorrow = starting_date.advance(:days => 1).to_i
      end_of_this_week = starting_date.sunday.to_i
      end_of_next_week = starting_date.sunday.advance(:weeks => 1).to_i

      if due < now
        bucket = "Overdue"
      elsif due >= now && due < tomorrow
        bucket = "Due Today"
      elsif due >= tomorrow && due <= end_of_this_week
        bucket = "Due This Week"
      elsif due > end_of_this_week && due <= end_of_next_week
        bucket = "Due Next Week"
      else
        # Too far in the future, drop the event
        bucket = "far future"
      end

      Rails.logger.debug "#{self.class.name} In determine_bucket, @starting_date = #{starting_date}, now = #{now_time}; formatted entry = #{formatted_entry}"
    end
    bucket
  end

  def format_date_into_entry!(due, formatted_entry, field_name)
    if !due.blank?
      formatted_entry[field_name] = {
        "epoch" => due.to_i,
        "datetime" => due.rfc3339(3),
        "date_string" => due.strftime("%-m/%d")
      }
    end
  end

  def convert_due_date(due_date)
    if due_date.blank?
      nil
    else
      DateTime.parse(due_date.to_s)
    end
  end
end