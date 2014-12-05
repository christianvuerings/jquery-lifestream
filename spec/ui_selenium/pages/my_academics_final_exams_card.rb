require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_academics_page'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyAcademicsFinalExamsCard < MyAcademicsPage

    include PageObject
    include CalCentralPages
    include ClassLogger



  end
end