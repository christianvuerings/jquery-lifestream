require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyDashboardPage

    include PageObject
    include CalCentralPages

    wait_for_expected_title('Dashboard | CalCentral', WebDriverUtils.page_load_timeout)

    h2(:connect_bconnected_heading, :xpath => '//h2[contains(.,"Connect CalCentral to bConnected")]')
    button(:connect_bconnected_button, :xpath => '//button[@data-ng-click="api.user.enableOAuth(\'Google\')"]')

    # TO DO
    h2(:to_do_heading, :xpath => '//h2[contains(.,"To Do")]')
    button(:completed_tasks_tab, :xpath => '//button[contains(.,"completed")]')
    paragraph(:no_tasks_message, :xpath => '//p[contains(.,"You have no tasks and assignments.")]')

    # ADD/EDIT TASK INPUTS
    button(:new_task_button, :xpath => '//button[contains(.,"New Task")]')
    text_field(:task_title_input, :xpath => '//input[@data-ng-model="addEditTask.title"]')
    text_field(:task_date_input, :xpath => '//input[@data-ng-model="addEditTask.dueDate"]')
    text_field(:task_notes_input, :xpath => '//input[@data-ng-model="addEditTask.notes"]')
    button(:add_task_button, :xpath => '//button[contains(.,"Add Task")]')
    button(:cancel_task_button, :xpath => '//button[contains(.,"Cancel")]')


    # TASKS: SCHEDULED
    button(:scheduled_tasks_tab, :xpath => '//button[contains(.,"scheduled")]')
    span(:overdue_task_count, :xpath => '//span[contains(.,"Overdue")]/following-sibling::span')
    link(:overdue_task_one, :xpath => '//li[@data-ng-repeat="task in overdueTasks"]//div[@data-ng-click="api.widget.toggleShow($event, tasks, task, \'Tasks\')"]//strong')
    button(:overdue_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in overdueTasks"]//button[contains(.,"Edit")]')
    button(:overdue_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in overdueTasks"]//button[contains(.,"Delete")]')
    checkbox(:overdue_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in overdueTasks"]//input[@id="cc-wdiget-tasks-checkbox-0"]')
    span(:today_task_count, :xpath => '//span[contains(.,"Today")]/following-sibling::span')
    link(:today_task_one, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks"]//div[@data-ng-click="api.widget.toggleShow($event, tasks, task, \'Tasks\')"]')
    button(:today_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks"]//button[contains(.,"Edit")]')
    button(:today_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks"]//button[contains(.,"Delete")]')
    checkbox(:today_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in overdueTasks"]//input[@id="cc-wdiget-tasks-checkbox-0"]')
    span(:future_task_count, :xpath => '//span[contains(.,"Future")]/following-sibling::span')
    link(:future_task_one, :xpath => '//li[@data-ng-repeat="task in futureTasks"]//div[@data-ng-click="api.widget.toggleShow($event, tasks, task, \'Tasks\')"]')
    button(:future_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in futureTasks"]//button[contains(.,"Edit")]')
    button(:future_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in futureTasks"]//button[contains(.,"Delete")]')
    checkbox(:today_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in overdueTasks"]//input[@id="cc-wdiget-tasks-checkbox-0"]')

    # TASKS: UNSCHEDULED
    button(:unscheduled_tasks_tab, :xpath => '//button[contains(.,"unscheduled")]')
    span(:unscheduled_task_count, :xpath => '//span[contains(.,"Unscheduled")]/following-sibling::span')
    link(:unscheduled_task_one, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks"]//div[@data-ng-click="api.widget.toggleShow($event, tasks, task, \'Tasks\')"]')
    button(:unscheduled_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks"]//button[contains(.,"Edit")]')
    button(:unscheduled_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks"]//button[contains(.,"Delete")]')
    checkbox(:unscheduled_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks"]//input[@id="cc-wdiget-tasks-checkbox-0"]')

    # TASKS: COMPLETED
    button(:completed_tasks_tab, :xpath => '//div[@class="cc-widget-tasks-container"]//li[3]/button')
    button(:delete_completed_tasks_button, :xpath => '//button[contains(.,"Delete completed tasks")]')
    h3(:completed_task_count, :xpath => '//h3[contains(.,"Total")]/span')
    link(:completed_task_one, :xpath => '//li[@data-ng-repeat="task in completedTasks"]//div[@data-ng-click="api.widget.toggleShow($event, tasks, task, \'Tasks\')"]')
    button(:completed_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in completedTasks"]//button[contains(.,"Edit")]')
    button(:completed_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in completedTasks"]//button[contains(.,"Delete")]')
    checkbox(:completed_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in completedTasks"]//input[@id="cc-wdiget-tasks-checkbox-0"]')


    h2(:recent_activity_heading, :xpath => '//h2[contains(.,"Recent Activity")]')

    def load_page(driver)
      Rails.logger.info('Loading My Dashboard page')
      driver.get(WebDriverUtils.base_url + '/dashboard')
    end

    def click_new_task_button
      Rails.logger.info('Clicking new task button')
      new_task_button_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
      new_task_button
    end

    def input_task(title, date, note)
      Rails.logger.info('Task title is ' + title)
      task_title_input_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
      self.task_title_input = title
      if date != nil
        Rails.logger.info('Task date is ' + date)
        self.task_date_input = date
      end
      if note != nil
        Rails.logger.info('Task note is ' + note)
        self.task_notes_input = note
      end
    end

    def click_add_task_button
      Rails.logger.info('Clicking add task button')
      add_task_button
    end

    def click_cancel_task_button
      Rails.logger.info('Clicking cancel button')
      cancel_task_button
    end

    def delete_all_existing_tasks
      Rails.logger.info('Deleting existing tasks')
      scheduled_tasks_tab_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      scheduled_tasks_tab
      while overdue_task_one? do
        Rails.logger.info('killing overdue tasks')
        overdue_task_one
        overdue_task_one_delete_button_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        overdue_task_one_delete_button
        sleep(WebDriverUtils.page_event_timeout)
      end
      while today_task_one? do
        Rails.logger.info('killing today tasks')
        today_task_one
        today_task_one_delete_button_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        today_task_one_delete_button
        sleep(WebDriverUtils.page_event_timeout)
      end
      while future_task_one? do
        Rails.logger.info('killing future tasks')
        future_task_one
        future_task_one_delete_button_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        future_task_one_delete_button
        sleep(WebDriverUtils.page_event_timeout)
      end
      unscheduled_tasks_tab
      while unscheduled_task_one? do
        Rails.logger.info('killing unscheduled tasks')
        unscheduled_task_one
        unscheduled_task_one_delete_button_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        unscheduled_task_one_delete_button
        sleep(WebDriverUtils.page_event_timeout)
      end
      completed_tasks_tab
      while completed_task_one? do
        Rails.logger.info('killing completed tasks')
        delete_completed_tasks_button_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        delete_completed_tasks_button
        sleep(WebDriverUtils.page_event_timeout)
      end
    end





  end
end
