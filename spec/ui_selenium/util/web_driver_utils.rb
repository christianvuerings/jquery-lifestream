require 'selenium-webdriver'

class WebDriverUtils

  @config = YAML::load_file(File.join(File.dirname(File.expand_path(__FILE__)), 'settings.yml'))

  def self.driver
    if @config['webDriver'] == 'firefox'
      Selenium::WebDriver.for :firefox
    elsif @config['webDriver'] == 'chrome'
      Selenium::WebDriver.for :chrome
    elsif @config['webDriver'] == 'safari'
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

end