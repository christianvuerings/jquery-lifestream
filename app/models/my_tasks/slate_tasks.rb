module MyTasks
  class SlateTasks
    include MyTasks::TasksModule, ClassLogger, HtmlSanitizer, SafeJsonParser

    def initialize(uid, starting_date)
      @uid = uid
      @starting_date = starting_date
      @now_time = Time.zone.now
    end

    def fetch_tasks
      tasks = []
      checklist_feed = Slate::Checklist.new(user_id: @uid).get
      checklist_results = collect_results(checklist_feed) { |result| format_checklist result }
      tasks.concat checklist_results.compact if checklist_results
      tasks
    end

    private

    def collect_results(response)
      collected_results = []
      if (response && response[:feed] && response[:feed]['PERSON_CHKLST'] && results = response[:feed]['PERSON_CHKLST']['PERSON_CHKLST_ITEM'])
        logger.info "Sorting Slate Checklist feed into buckets with starting_date #{@starting_date}; #{results}"
        results.each do |result|
          if (formatted_entry = yield result)
            logger.debug "Adding Slate Checklist task with dueDate: #{formatted_entry['dueDate']} in bucket '#{formatted_entry['bucket']}': #{formatted_entry}"
            collected_results << formatted_entry
          end
        end
      end
      collected_results
    end

    def entry_from_result(result)
      {
        emitter: Slate::Checklist::APP_ID,
        linkDescription: "View in #{Slate::Checklist::APP_NAME}",
        linkUrl: 'http://sisproject.berkeley.edu',
        sourceUrl: 'http://sisproject.berkeley.edu',
        status: 'inprogress',
        title: "#{result['CHKLST_ITEM_CD']}: #{result['CHECKLIST_CD_DESCR']}",
        type: 'task'
      }
    end

    def format_date_and_bucket(formatted_entry, date)
      format_date_into_entry!(date, formatted_entry, :dueDate)
      formatted_entry[:bucket] = determine_bucket(date, formatted_entry, @now_time, @starting_date)
    end

    def format_checklist(result)
      return nil if result['CHKLST_ITEM_CD'].blank? || result['CHECKLIST_CD_DESCR'].blank?
      formatted_entry = entry_from_result result
      due_date = convert_datetime_or_date result['DUE_DT']
      format_date_and_bucket(formatted_entry, due_date)
      if due_date
        formatted_entry[:dueDate][:hasTime] = due_date.is_a?(DateTime)
      end
      if formatted_entry[:bucket] == 'Unscheduled'
        # TODO front-end code needs an updated_date for sorting. See if we can get that from the Slate feed somehow.
        updated_date = DateTime.now
        format_date_into_entry!(updated_date, formatted_entry, :updatedDate)
      end
      formatted_entry
    end

  end
end
