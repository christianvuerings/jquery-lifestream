require 'selenium-webdriver'

class WebDriverUtils

  include ClassLogger

  def self.launch_browser
    # Sometimes browser does not launch successfully, so try twice
    tries ||= 2
    logger.info('Launching browser')
    if Settings.ui_selenium.webDriver == 'firefox'
      Selenium::WebDriver.for :firefox
    elsif Settings.ui_selenium.webDriver == 'chrome'
      Selenium::WebDriver.for :chrome
    elsif Settings.ui_selenium.webDriver == 'safari'
      Selenium::WebDriver.for :safari
    end
  rescue => e
    logger.error('Browser failed to launch')
    logger.error e.message + "\n" + e.backtrace.join("\n")
    retry unless (tries -= 1).zero?
  end

  def self.quit_browser(driver)
    logger.info 'Quitting the browser'
    # If the browser did not start successfully, the quit method will fail.
    driver.quit rescue NoMethodError
    # Pause after quitting the browser to make sure it shuts down completely before the next test relaunches it
    sleep(3)
  end

  def self.base_url
    Settings.ui_selenium.baseUrl
  end

  def self.cal_net_url
    Settings.ui_selenium.calNetUrl
  end

  def self.google_auth_url
    Settings.ui_selenium.googleAuthUrl
  end

  def self.page_load_timeout
    Settings.ui_selenium.pageLoadTimeout
  end

  def self.financials_timeout
    Settings.ui_selenium.financialsTimeout
  end

  def self.academics_timeout
    Settings.ui_selenium.academicsTimeout
  end

  def self.fin_aid_timeout
    Settings.ui_selenium.finAidTimeout
  end

  def self.fin_resources_links_timeout
    Settings.ui_selenium.finResourcesLinksTimeout
  end

  def self.google_oauth_timeout
    Settings.ui_selenium.googleOauthTimeout
  end

  def self.google_task_timeout
    Settings.ui_selenium.googleTaskTimeout
  end

  def self.page_event_timeout
    Settings.ui_selenium.pageEventTimeout
  end

  def self.mail_live_update_timeout
    Settings.cache.expiration.marshal_dump["MyBadges::GoogleMail".to_sym] + Settings.ui_selenium.liveUpdateTimeoutDelta
  end

  def self.tasks_live_update_timeout
    Settings.cache.expiration.marshal_dump["MyTasks::GoogleTasks".to_sym] + Settings.ui_selenium.liveUpdateTimeoutDelta
  end

  def self.live_users
    File.join(CalcentralConfig.local_dir, "uids.json")
  end

  def self.ui_date_display_format(date)
    today = Date.today
    if date.strftime("%Y") == today.strftime("%Y")
      date_format = date.strftime("%m/%d")
    else
      date_format = date.strftime("%m/%d/%Y")
    end
    date_format
  end

  def self.ui_date_input_format(date)
    date.strftime("%m/%d/%Y")
  end

  def self.verify_external_link(driver, link, expected_page_title)
    begin
      link.click
      if driver.window_handles.length > 1
        driver.switch_to.window driver.window_handles.last
        wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.page_load_timeout)
        wait.until { driver.find_element(:xpath => "//title[contains(.,'#{expected_page_title}')]") }
        true
      else
        logger.error('Link did not open in a new window')
        false
      end
    rescue
      false
    ensure
      if driver.window_handles.length > 1
        # Handle any alert that might appear when opening the new window
        driver.switch_to.alert.accept rescue Selenium::WebDriver::Error::NoAlertPresentError
        driver.close
        # Handle any alert that might appear when closing the new window
        driver.switch_to.alert.accept rescue Selenium::WebDriver::Error::NoAlertPresentError
      end
      driver.switch_to.window driver.window_handles.first
    end
  end
end
