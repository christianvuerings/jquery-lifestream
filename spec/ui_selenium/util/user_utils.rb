require 'selenium-webdriver'
require 'page-object'
require_relative '../pages/cal_central_pages'
require_relative '../pages/settings_page'
require_relative '../pages/cal_net_auth_page'
require_relative '../util/web_driver_utils'

class UserUtils

  include PageObject
  include CalCentralPages

  @config = YAML.load_file((ENV['HOME'] + '/.calcentral_config/production.local.yml'))

  def self.basic_auth_pass
    @config['developer_auth']['password']
  end

  def self.oski_username
    @config['calnet_oski']['username']
  end

  def self.oski_password
    @config['calnet_oski']['password']
  end

  def self.test_password
    @config['calnet_test']['password']
  end

end