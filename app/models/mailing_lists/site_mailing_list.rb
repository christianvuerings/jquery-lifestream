module MailingLists
  class SiteMailingList < ActiveRecord::Base
    include ActiveRecordHelper

    self.table_name = 'canvas_site_mailing_lists'

    attr_accessible :canvas_site_id, :list_name, :state, :populated_at

  end
end
