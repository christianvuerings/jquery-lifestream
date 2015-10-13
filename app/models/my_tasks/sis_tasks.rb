module MyTasks
  class SisTasks
    include MyTasks::TasksModule, ClassLogger, HtmlSanitizer, SafeJsonParser

    def initialize(uid, starting_date)
      @uid = uid
      @starting_date = starting_date
      @now_time = Time.zone.now
    end

    def fetch_tasks
      tasks = []
      checklist_feed = CampusSolutions::Checklist.new(user_id: @uid).get
      checklist_results = collect_results(checklist_feed) { |result| format_checklist result }
      tasks.concat checklist_results.compact if checklist_results
      tasks
    end

    private

    def collect_results(response)
      collected_results = []
      if (response && response[:feed] && results = response[:feed][:checkListItems])
        logger.info "Sorting SIS Checklist feed into buckets with starting_date #{@starting_date}; #{results}"
        results.each do |result|
          if (formatted_entry = yield result)
            logger.debug "Adding Checklist task with dueDate: #{formatted_entry[:dueDate]} in bucket '#{formatted_entry[:bucket]}': #{formatted_entry}"
            collected_results << formatted_entry
          end
        end
      end
      collected_results
    end

    def entry_from_result(result)
      status = 'inprogress'
      if %w(Completed Paidoff Waived Cancelled).include?(result[:itemStatus])
        status = 'completed'
      end
      {
        emitter: CampusSolutions::Proxy::APP_NAME,
        linkDescription: result[:checkListDocMgmt][:linkUrlLbl],
        linkUrl: result[:checkListDocMgmt][:linkUrl],
        sourceUrl: 'http://sis-project.berkeley.edu',
        status: status,
        title: result[:checkListDescr],
        notes: result[:itemComment],
        type: 'task',
        subTitle: result[:responsibleCntctName],
        showStatus: result[:itemStatus],
        responsibleContactEmail: result[:responsibleCntctEmail],
        organization: result[:associationIdName]
      }
    end

    def format_date_and_bucket(formatted_entry, date)
      format_date_into_entry!(date, formatted_entry, :dueDate)
      formatted_entry[:bucket] = determine_bucket(date, formatted_entry, @now_time, @starting_date)
    end

    def format_checklist(result)
      unless result.is_a?(Hash) && result[:checkListDescr].present?
        return nil
      end
      formatted_entry = entry_from_result result
      due_date = convert_datetime_or_date result[:dueDt]
      format_date_and_bucket(formatted_entry, due_date)
      if due_date
        formatted_entry[:dueDate][:hasTime] = due_date.is_a?(DateTime)
      end
      if formatted_entry[:bucket] == 'Unscheduled'
        # TODO front-end code needs an updated_date for sorting. See if we can get that from the CS feed somehow.
        updated_date = DateTime.now.midnight
        format_date_into_entry!(updated_date, formatted_entry, :updatedDate)
      end
      formatted_entry
    end

  end
end
