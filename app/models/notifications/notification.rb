module Notifications
  class Notification < ActiveRecord::Base
    include ActiveRecordHelper, SafeJsonParser

    after_initialize :log_access
    attr_accessible :uid, :data, :translator, :occurred_at

    def data
      safe_json(read_attribute(:data))
    end

    def data=(obj)
      write_attribute(:data, obj.to_json.to_s)
    end

  end
end
