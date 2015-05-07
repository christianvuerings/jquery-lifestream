module User
  class SavedUid < ActiveRecord::Base
    include ActiveRecordHelper

    self.table_name = 'saved_uids'

    belongs_to :data, :class_name => 'User::Data', :foreign_key => 'owner_id'

    attr_accessible :stored_uid

  end
end
