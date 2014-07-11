module Calendar
  class User < ActiveRecord::Base

    self.table_name = 'class_calendar_users'

    attr_accessible :uid, :alternate_email

  end

end
