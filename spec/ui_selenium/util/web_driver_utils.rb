require 'selenium-webdriver'

class WebDriverUtils

  @config = YAML::load_file(File.join(File.dirname(File.expand_path(__FILE__)), 'settings.yml'))

  def self.driver
    if @config['webDriver'] == 'firefox'
      Rails.logger.info('Browser is Firefox')
      Selenium::WebDriver.for :firefox
    elsif @config['webDriver'] == 'chrome'
      Rails.logger.info('Browser is Chrome')
      Selenium::WebDriver.for :chrome
    elsif @config['webDriver'] == 'safari'
      Rails.logger.info('Browser is Safari')
      Selenium::WebDriver.for :safari
    end
  rescue
    puts 'No driver defined'
  end

  def self.base_url
    @config['baseUrl']
  end

  def self.cal_net_url
    @config['calNetUrl']
  end

  def self.page_load_timeout
    @config['pageLoadTimeout']
  end

  def self.financials_timeout
    @config['financialsTimeout']
  end

  def self.fin_resources_links_timeout
    @config['finResourcesLinksTimeout']
  end

  def self.page_event_timeout
    @config['pageEventTimeout']
  end

  def self.live_users
    ENV['HOME'] + '/.calcentral_config/selenium-uids.csv'
  end

end