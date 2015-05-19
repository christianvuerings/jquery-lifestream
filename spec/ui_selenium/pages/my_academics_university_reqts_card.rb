require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_academics_page'

module CalCentralPages

  class MyAcademicsUniversityReqtsCard < MyAcademicsPage

    # UNIVERSITY UNDERGRAD REQTS
    table(:reqts_table, :xpath => '//h2[text()="University Requirements"]/../following-sibling::div//table')
    span(:writing_reqt_met, :xpath => '//span[text()="UC Entry Level Writing"]/following-sibling::span[text()="Completed"]')
    link(:writing_reqt_unmet, :xpath => '//span[text()="UC Entry Level Writing"]/following-sibling::a[contains(text(),"Incomplete")]')
    span(:history_reqt_met, :xpath => '//span[text()="American History"]/following-sibling::span[text()="Completed"]')
    link(:history_reqt_unmet, :xpath => '//span[text()="American History"]/following-sibling::a[contains(text(),"Incomplete")]')
    span(:institutions_reqt_met, :xpath => '//span[text()="American Institutions"]/following-sibling::span[text()="Completed"]')
    link(:institutions_reqt_unmet, :xpath => '//span[text()="American Institutions"]/following-sibling::a[contains(text(),"Incomplete")]')
    span(:cultures_reqt_met, :xpath => '//span[text()="American Cultures"]/following-sibling::span[text()="Completed"]')
    link(:cultures_reqt_unmet, :xpath => '//span[text()="American Cultures"]/following-sibling::a[contains(text(),"Incomplete")]')

  end

end
