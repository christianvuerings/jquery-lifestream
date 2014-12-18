require 'selenium-webdriver'

class WebDriverUtils

  include ClassLogger

  def self.driver
    if Settings.ui_selenium.webDriver == 'firefox'
      Rails.logger.info('Browser is Firefox')
      Selenium::WebDriver.for :firefox
    elsif Settings.ui_selenium.webDriver == 'chrome'
      Rails.logger.info('Browser is Chrome')
      Selenium::WebDriver.for :chrome
    elsif Settings.ui_selenium.webDriver == 'safari'
      Rails.logger.info('Browser is Safari')
      Selenium::WebDriver.for :safari
    end
  rescue => e
    Rails.logger.error('Unable to initialize the designated WebDriver')
    Rails.logger.error e.message + "\n" + e.backtrace.join("\n")
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

  def self.verify_external_link(driver, link, expected_page_title)
    begin
      link.click
      if driver.window_handles.length > 0
        driver.switch_to.window driver.window_handles.last
        wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.page_load_timeout)
        wait.until { driver.find_element(:xpath => "//title[contains(.,'#{expected_page_title}')]") }
        driver.close
        driver.switch_to.window driver.window_handles.last
        true
      else
        false
      end
    rescue
      false
    ensure
      if driver.window_handles.length > 1
        logger.info 'New window was not closed, closing.'
        driver.switch_to.window driver.window_handles.last
        driver.close
        driver.switch_to.window driver.window_handles.last
      end
    end
  end
end
