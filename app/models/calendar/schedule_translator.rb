module Calendar
  class ScheduleTranslator

    include ClassLogger

    def initialize(schedule, term)
      @schedule = schedule
      @term = term
      logger.info "Schedule from Oracle: #{schedule}; term start: #{@term.classes_start}, term end: #{@term.classes_end}"
    end

    def recurrence_rule
      days = @schedule['meeting_days']
      if days.blank?
        return nil
      end
      byday = []
      if days.length > 0 && !days[0].blank?
        byday << 'SU'
      end
      if days.length > 1 && !days[1].blank?
        byday << 'MO'
      end
      if days.length > 2 && !days[2].blank?
        byday << 'TU'
      end
      if days.length > 3 && !days[3].blank?
        byday << 'WE'
      end
      if days.length > 4 && !days[4].blank?
        byday << 'TH'
      end
      if days.length > 5 && !days[5].blank?
        byday << 'FR'
      end
      if days.length > 6 && !days[6].blank?
        byday << 'SA'
      end

      if byday.empty?
        return nil
      end

      rrule = Icalendar::Values::Recur.new ''
      rrule.by_day = byday
      rrule.frequency = 'WEEKLY'
      # TODO should "until" be the end of classes or (as it is here) the end of instruction? end of classes is 1 week earlier.
      rrule.until = "#{@term.classes_end.utc.strftime Icalendar::Values::DateTime::FORMAT}Z"
      rrule = "RRULE:#{rrule.value_ical}"
      logger.info "Class Recurrence Rule: #{rrule}"
      rrule
    end

    def times
      if @schedule.blank? || @schedule['meeting_days'].blank?
        return nil
      end

      # figure out the first meeting date after the start of term
      classes_start_wday = @term.classes_start.wday
      first_wday_after_classes_start = -1
      days = @schedule['meeting_days']
      for i in 0..days.length do
        if days[i].present? && i >= classes_start_wday
          first_wday_after_classes_start = i
          break
        end
      end
      if first_wday_after_classes_start == -1
        # class starts the week after start of term
        for i in 0..days.length do
          if days[i].present?
            first_wday_after_classes_start = i + 7
            break
          end
        end
      end
      first_meeting = @term.classes_start + (first_wday_after_classes_start - classes_start_wday)

      # now that we know the first meeting date, figure out the start time
      time_start = @schedule['meeting_start_time'].gsub(/^0/, '')
      minute_start = time_start.slice!(-2, 2).to_i
      hour_start = time_start.to_i
      if hour_start < 12 && @schedule['meeting_start_time_ampm_flag'] == 'P'
        hour_start += 12
      end

      # and the end time
      time_end = @schedule['meeting_end_time'].gsub(/^0/, '')
      minute_end = time_end.slice!(-2, 2).to_i
      hour_end = time_end.to_i
      if hour_end < 12 && @schedule['meeting_end_time_ampm_flag'] == 'P'
        hour_end += 12
      end

      start_datetime = first_meeting.change({hour: hour_start, min: minute_start})
      end_datetime = first_meeting.change({hour: hour_end, min: minute_end})
      times = {
        start: start_datetime,
        end: end_datetime
      }
      logger.info "Class Meeting Times: #{times}"
      times
    end
  end
end
