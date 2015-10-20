require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_dashboard_page'
require_relative '../util/web_driver_utils'

module CalCentralPages

  class MyDashboardTasksCard < MyDashboardPage

    include PageObject
    include CalCentralPages
    include ClassLogger

    # TASKS
    button(:completed_tasks_tab, :xpath => '//button[contains(.,"completed")]')
    paragraph(:no_tasks_message, :xpath => '//p[contains(.,"You have no tasks and assignments.")]')
    button(:scheduled_tasks_tab, :xpath => '//button[contains(.,"scheduled")]')
    button(:unsched_tasks_tab, :xpath => '//button[contains(.,"unscheduled")]')
    button(:completed_tasks_tab, :xpath => '//div[@class="cc-widget-tasks-container"]//li[3]/button')

    # ADD/EDIT TASK
    button(:new_task_button, :xpath => '//button[contains(.,"New Task")]')
    text_field(:new_task_title_input, :xpath => '//input[@data-ng-model="addEditTask.title"]')
    text_field(:new_task_date_input, :xpath => '//input[@data-ng-model="addEditTask.dueDate"]')
    text_field(:new_task_notes_input, :xpath => '//textarea[@data-ng-model="addEditTask.notes"]')
    button(:add_new_task_button, :xpath => '//button[contains(.,"Add Task")]')
    button(:cancel_new_task_button, :xpath => '//button[contains(.,"Cancel")]')
    paragraph(:new_task_date_validation_error, :xpath => '//p[@data-ng-show="cc_widget_tasks_form.add_task_due_date.$error.ccDateValidator"]')

    # TASKS: OVERDUE
    span(:overdue_task_count, :xpath => '//span[@data-ng-bind="overdueTasks.length"]')
    list_item(:overdue_task_one, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]')
    link(:overdue_task_one_toggle, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//span[contains(.,"Show more information about")]')
    button(:overdue_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//button[contains(.,"Edit")]')
    button(:overdue_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//button[contains(.,"Delete")]')
    button(:overdue_task_one_save_button, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//button[contains(.,"Save")]')
    checkbox(:overdue_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//input[@id="cc-widget-tasks-checkbox-0"]')
    div(:overdue_task_one_title, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//strong')
    text_field(:overdue_task_one_title_input, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//input[@data-ng-model="addEditTask.title"]')
    span(:overdue_task_one_course, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//span[@data-ng-bind="task.course_code"]')
    div(:overdue_task_one_date, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//div[@class="cc-widget-tasks-col cc-widget-tasks-col-date"]/span')
    div(:overdue_task_one_time, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//div[@data-ng-if="task.emitter==\'bCourses\' && task.dueDate.hasTime"]')
    text_field(:overdue_task_one_date_input, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//input[@name="add_task_due_date"]')
    div(:overdue_task_one_notes, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//div[@data-ng-bind-html="task.notes | linky"]')
    text_field(:overdue_task_one_notes_input, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//textarea[@data-ng-model="addEditTask.notes"]')
    link(:overdue_task_one_bcourses_link, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//a[contains(.,"View in bCourses")]')
    button(:overdue_show_more_button, :xpath => '//div[@data-cc-show-more-limit="overdueLimit"]/button')
    div(:last_overdue_task_title, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"][last()]//strong')
    div(:last_overdue_task_date, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"][last()]//div[@class="cc-widget-tasks-col cc-widget-tasks-col-date"]/span')

    # TASKS: TODAY
    span(:today_task_count, :xpath => '//span[@data-ng-bind="dueTodayTasks.length"]')
    list_item(:today_task_one, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]')
    link(:today_task_one_toggle, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//span[contains(.,"Show more information about")]')
    button(:today_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//button[contains(.,"Edit")]')
    button(:today_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//button[contains(.,"Delete")]')
    button(:today_task_one_save_button, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//button[contains(.,"Save")]')
    button(:today_task_one_cancel_button, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//button[contains(.,"Cancel")][2]')
    checkbox(:today_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//input[@id="cc-widget-tasks-checkbox-0"]')
    div(:today_task_one_title, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//strong')
    span(:today_task_one_course, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//span[@data-ng-bind="task.course_code"]')
    text_field(:today_task_one_title_input, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//input[@data-ng-model="addEditTask.title"]')
    div(:today_task_one_date, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//div[@class="cc-widget-tasks-col cc-widget-tasks-col-date"]/span')
    div(:today_task_one_time, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//div[@data-ng-if="task.emitter==\'bCourses\' && task.dueDate.hasTime"]')
    text_field(:today_task_one_date_input, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//input[@name="add_task_due_date"]')
    div(:today_task_one_notes, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//div[@data-ng-bind-html="task.notes | linky"]')
    text_field(:today_task_one_notes_input, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//textarea[@data-ng-model="addEditTask.notes"]')
    link(:today_task_one_bcourses_link, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//a[contains(.,"View in bCourses")]')
    button(:today_show_more_button, :xpath => '//div[@data-cc-show-more-limit="dueTodayLimit"]/button')
    paragraph(:today_task_date_validation_error, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//p[@data-ng-show="cc_widget_tasks_form.add_task_due_date.$error.ccDateValidator"]')
    div(:last_today_task_title, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"][last()]//strong')
    div(:last_today_task_date, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"][last()]//div[@class="cc-widget-tasks-col cc-widget-tasks-col-date"]/span')

    # TASKS: FUTURE
    span(:future_task_count, :xpath => '//span[@data-ng-bind="futureTasks.length"]')
    list_item(:future_task_one, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]')
    link(:future_task_one_toggle, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//span[contains(.,"Show more information about")]')
    button(:future_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//button[contains(.,"Edit")]')
    button(:future_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//button[contains(.,"Delete")]')
    button(:future_task_one_save_button, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//button[contains(.,"Save")]')
    checkbox(:future_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//input[@id="cc-widget-tasks-checkbox-0"]')
    div(:future_task_one_title, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//strong')
    span(:future_task_one_course, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//span[@data-ng-bind="task.course_code"]')
    text_field(:future_task_one_title_input, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//input[@data-ng-model="addEditTask.title"]')
    div(:future_task_one_date, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//div[@class="cc-widget-tasks-col cc-widget-tasks-col-date"]/span')
    div(:future_task_one_time, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//div[@data-ng-if="task.emitter==\'bCourses\' && task.dueDate.hasTime"]')
    text_field(:future_task_one_date_input, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//input[@name="add_task_due_date"]')
    div(:future_task_one_notes, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//div[@data-ng-bind-html="task.notes | linky"]')
    text_field(:future_task_one_notes_input, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//textarea[@data-ng-model="addEditTask.notes"]')
    link(:future_task_one_bcourses_link, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//a[contains(.,"View in bCourses")]')
    button(:future_show_more_button, :xpath => '//div[@data-cc-show-more-limit="futureLimit"]/button')
    div(:last_future_task_title, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"][last()]//strong')
    div(:last_future_task_date, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"][last()]//div[@class="cc-widget-tasks-col cc-widget-tasks-col-date"]/span')

    # TASKS: UNSCHEDULED
    span(:unsched_task_count, :xpath => '//span[@data-ng-bind="unscheduledTasks.length"]')
    list_item(:unsched_task_one, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]')
    link(:unsched_task_one_toggle, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//span[contains(.,"Show more information about")]')
    button(:unsched_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//button[contains(.,"Edit")]')
    button(:unsched_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//button[contains(.,"Delete")]')
    button(:unsched_task_one_save_button, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//button[contains(.,"Save")]')
    checkbox(:unsched_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//input[@id="cc-widget-tasks-checkbox-0"]')
    div(:unsched_task_one_title, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//strong')
    text_field(:unsched_task_one_title_input, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//input[@data-ng-model="addEditTask.title"]')
    div(:unsched_task_one_date, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//div[@data-ng-if="task.updatedDate && task.bucket === \'Unscheduled\'"]/span')
    text_field(:unsched_task_one_date_input, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//input[@name="add_task_due_date"]')
    div(:unsched_task_one_notes, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//div[@data-ng-bind-html="task.notes | linky"]')
    text_field(:unsched_task_one_notes_input, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//textarea[@data-ng-model="addEditTask.notes"]')
    button(:unsched_show_more_button, :xpath => '//div[@data-cc-show-more-limit="unscheduledLimit"]/button')
    div(:last_unsched_task_title, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"][last()]//strong')
    div(:last_unsched_task_date, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"][last()]//div[@data-ng-if="task.updatedDate && task.bucket === \'Unscheduled\'"]/span')

    # TASKS: COMPLETED
    button(:delete_completed_tasks_button, :xpath => '//button[contains(.,"Delete completed tasks")]')
    span(:completed_task_count, :xpath => '//span[@data-ng-bind="completedTasks.length"]')
    list_item(:completed_task_one, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]')
    link(:completed_task_one_toggle, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//span[contains(.,"Show more information about")]')
    button(:completed_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//button[contains(.,"Edit")]')
    button(:completed_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//button[contains(.,"Delete")]')
    checkbox(:completed_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//input[@id="cc-widget-tasks-checkbox-0"]')
    div(:completed_task_one_title, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//strong')
    text_field(:completed_task_one_title_input, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//input[@data-ng-model="addEditTask.title"]')
    text_field(:completed_task_one_date_input, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//input[@name="add_task_due_date"]')
    text_field(:completed_task_one_notes_input, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//textarea[@data-ng-model="addEditTask.notes"]')
    button(:completed_show_more_button, :xpath => '//div[@data-cc-show-more-limit="completedLimit"]/button')
    elements(:completed_task_titles, :list_item, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//div[@data-ng-hide="editorEnabled"]//strong')

    # ADD NEW TASK

    def edit_new_task(title, date, note)
      new_task_title_input_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
      unless title.nil?
        logger.info('Task title is ' + title)
        self.new_task_title_input = title
      end
      unless date.nil?
        logger.info('Task date is ' + date)
        self.new_task_date_input = date
      end
      unless note.nil?
        logger.info('Task note is ' + note)
        self.new_task_notes_input = note
      end
    end

    def click_add_task_button
      logger.info('Clicking add task button')
      WebDriverUtils.wait_for_page_and_click add_new_task_button_element
      add_new_task_button_element.when_not_visible(timeout=WebDriverUtils.google_task_timeout)
    end

    # OVERDUE TASKS

    def edit_overdue_task_one(title, date, note)
      overdue_task_one_title_input_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
      unless title.nil?
        logger.info('Task title is ' + title)
        self.overdue_task_one_title_input = title
      end
      unless date.nil?
        logger.info('Task date is ' + date)
        self.overdue_task_one_date_input = date
      end
      unless note.nil?
        logger.info('Task note is ' + note)
        self.overdue_task_one_notes_input = note
      end
    end

    def complete_overdue_task_one
      logger.info('Completing first overdue task')
      overdue_task_one_cbx_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
      task_count = overdue_task_count.to_i
      check_overdue_task_one_cbx
      wait_until(WebDriverUtils.google_task_timeout, nil) { overdue_task_count.to_i == (task_count - 1) }
    end

    def delete_all_overdue_tasks
      WebDriverUtils.wait_for_page_and_click scheduled_tasks_tab_element
      while overdue_task_one_toggle? do
        logger.info('Deleting task')
        task_count = overdue_task_count.to_i
        WebDriverUtils.wait_for_page_and_click overdue_task_one_toggle_element
        WebDriverUtils.wait_for_page_and_click overdue_task_one_delete_button_element
        wait_until(WebDriverUtils.google_task_timeout, nil) { overdue_task_count.to_i == (task_count - 1) }
      end
    end

    # TODAY'S TASKS

    def edit_today_task_one(title, date, note)
      today_task_one_title_input_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
      unless title.nil?
        logger.info('Task title is ' + title)
        self.today_task_one_title_input = title
      end
      unless date.nil?
        logger.info('Task date is ' + date)
        self.today_task_one_date_input = date
      end
      unless note.nil?
        logger.info('Task note is ' + note)
        self.today_task_one_notes_input = note
      end
    end

    def complete_today_task_one
      logger.info('Completing first task due today')
      today_task_one_cbx_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
      task_count = today_task_count.to_i
      check_today_task_one_cbx
      wait_until(WebDriverUtils.google_task_timeout, nil) { today_task_count.to_i == (task_count - 1) }
    end

    def delete_all_today_tasks
      WebDriverUtils.wait_for_page_and_click scheduled_tasks_tab_element
      while today_task_one_toggle? do
        logger.info('Deleting task')
        task_count = today_task_count.to_i
        WebDriverUtils.wait_for_page_and_click today_task_one_toggle_element
        WebDriverUtils.wait_for_page_and_click today_task_one_delete_button_element
        wait_until(WebDriverUtils.google_task_timeout, nil) { today_task_count.to_i == (task_count - 1) }
      end
    end

    # FUTURE TASKS

    def edit_future_task_one(title, date, note)
      future_task_one_title_input_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
      unless title.nil?
        logger.info('Task title is ' + title)
        self.future_task_one_title_input = title
      end
      unless date.nil?
        logger.info('Task date is ' + date)
        self.future_task_one_date_input = date
      end
      unless note.nil?
        logger.info('Task note is ' + note)
        self.future_task_one_notes_input = note
      end
    end

    def complete_future_task_one
      logger.info('Completing first future task')
      future_task_one_cbx_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
      task_count = future_task_count.to_i
      check_future_task_one_cbx
      wait_until(WebDriverUtils.google_task_timeout, nil) { future_task_count.to_i == (task_count - 1) }
    end

    def delete_all_future_tasks
      WebDriverUtils.wait_for_page_and_click scheduled_tasks_tab_element
      while future_task_one_toggle? do
        logger.info('Deleting task')
        task_count = future_task_count.to_i
        WebDriverUtils.wait_for_page_and_click future_task_one_toggle_element
        WebDriverUtils.wait_for_page_and_click future_task_one_delete_button_element
        wait_until(WebDriverUtils.google_task_timeout, nil) { future_task_count.to_i == (task_count - 1) }
      end
    end

    # UNSCHEDULED TASKS

    def edit_unsched_task_one(title, date, note)
      unsched_task_one_title_input_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
      unless title.nil?
        logger.info('New title is ' + title)
        self.unsched_task_one_title_input = title
      end
      unless date.nil?
        logger.info('New date is ' + date)
        self.unsched_task_one_date_input = date
      end
      unless note.nil?
        logger.info('Task note is ' + note)
        self.unsched_task_one_notes_input = note
      end
    end

    def complete_unsched_task_one
      logger.info('Completing first unscheduled task')
      unsched_task_one_cbx_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
      task_count = unsched_task_count.to_i
      check_unsched_task_one_cbx
      wait_until(WebDriverUtils.google_task_timeout, nil) { unsched_task_count.to_i == (task_count - 1) }
      logger.info('Task completed')
    end

    def delete_all_unscheduled_tasks
      WebDriverUtils.wait_for_page_and_click unsched_tasks_tab_element
      while unsched_task_one_toggle? do
        logger.info('Deleting task')
        task_count = unsched_task_count.to_i
        WebDriverUtils.wait_for_page_and_click unsched_task_one_toggle_element
        WebDriverUtils.wait_for_page_and_click unsched_task_one_delete_button_element
        wait_until(WebDriverUtils.google_task_timeout, nil) { unsched_task_count.to_i == (task_count - 1) }
      end
    end

    # COMPLETED TASKS

    def uncomplete_task_one
      logger.info('Un-completing the first completed task')
      completed_task_one_cbx_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
      uncheck_completed_task_one_cbx
    end

    def all_completed_task_titles
      titles = []
      completed_task_titles_elements.each { |title| titles.push(title.text)}
      titles
    end

    def delete_all_completed_tasks
      WebDriverUtils.wait_for_page_and_click completed_tasks_tab_element
      while completed_task_one_toggle? do
        logger.info('Deleting task')
        WebDriverUtils.wait_for_page_and_click delete_completed_tasks_button_element
        wait_until(WebDriverUtils.google_task_timeout, nil) { !completed_task_one_toggle? }
        logger.info('Task deleted')
      end
    end

    def delete_all_tasks
      logger.info('Deleting all existing tasks')
      load_page
      self.delete_all_unscheduled_tasks
      self.delete_all_today_tasks
      self.delete_all_future_tasks
      self.delete_all_overdue_tasks
      self.delete_all_completed_tasks
    end
  end
end
