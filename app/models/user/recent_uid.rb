module User
  class RecentUid < ActiveRecord::Base
    include ActiveRecordHelper

    MAX_PER_OWNER_ID = 30

    self.table_name = 'recent_uids'

    belongs_to :data, :class_name => 'User::Data', :foreign_key => 'owner_id'

    attr_accessible :stored_uid

    before_create :limit_by_owner_id

    def limit_by_owner_id
      record_ids = self.class.where(owner_id: self.owner_id.to_s).order(:created_at).pluck(:id)
      if record_ids.count >= MAX_PER_OWNER_ID
        self.class.delete record_ids.slice(0..-MAX_PER_OWNER_ID)
      end
    end

  end
end
