module User
  class StoredUsers
    include ActiveRecordHelper

    def self.get(uid)
      users = {
        :saved => [],
        :recent => []
      }

      uid_entries = get_stored_uid_entries(uid)

      all_uids = []

      uid_entries[:saved].each do |entry|
        all_uids << entry[:stored_uid]
      end

      uid_entries[:recent].each do |entry|
        all_uids << entry[:stored_uid]
      end

      return users unless all_uids.present?

      users_found = User::SearchUsersByUid.new(:ids => all_uids).search_users_by_uid_batch
      uid_hash = {}

      users_found.each do |user|
        uid_hash[user['ldap_uid']] = user
      end

      saved_uid_set = Set.new

      uid_entries[:saved].each do |entry|
        user = uid_hash[entry[:stored_uid]]
        if user.present?
          saved_uid_set.add entry[:stored_uid]
          users[:saved] << user
        end
      end

      uid_entries[:recent].each do |entry|
        user = uid_hash[entry[:stored_uid]]
        if user.present?
          users[:recent] << user.merge('saved' => saved_uid_set.include?(entry[:stored_uid]))
        end
      end

      users
    end

    def self.store_saved_uid(uid, uid_to_store)
      user = get_user(uid)
      return error_response("Could not find user #{uid}.") unless user
      store(user.saved_uids, uid, uid_to_store)
    end

    def self.store_recent_uid(uid, uid_to_store)
      user = get_user(uid)
      return error_response("Could not find user #{uid}.") unless user
      store(user.recent_uids, uid, uid_to_store)
    end

    def self.delete_saved_uid(uid, uid_to_delete)
      user = get_user(uid)
      return error_response("Could not find user #{uid}.") unless user
      delete(user.saved_uids, uid, uid_to_delete)
    end

    def self.delete_recent_uid(uid, uid_to_delete)
      user = get_user(uid)
      return error_response("Could not find user #{uid}.") unless user
      delete(user.recent_uids, uid, uid_to_delete)
    end

    def self.delete_all_recent(uid)
      user = get_user(uid)
      return error_response("Could not find user #{uid}.") unless user
      delete_all(user.recent_uids)
    end

    def self.delete_all_saved(uid)
      user = get_user(uid)
      return error_response("Could not find user #{uid}.") unless user
      delete_all(user.saved_uids)
    end

    private

    def self.get_stored_uid_entries(uid)
      stored_entries = {
        :saved => [],
        :recent => []
      }
      user = get_user(uid)
      if user
        stored_entries[:saved] = user.saved_uids.order(:created_at).reverse_order
        stored_entries[:recent] = user.recent_uids.order(:created_at).reverse_order
      end
      stored_entries
    end

    def self.store(model, uid, uid_to_store)
      if (model.where(:stored_uid => uid_to_store.to_s).size == 0)
        model.create(:stored_uid => uid_to_store.to_s)
        success_response
      else
        error_response("UID #{uid_to_store} is already stored.")
      end
    end

    def self.delete(model, uid, uid_to_delete)
      found = model.where(:stored_uid => uid_to_delete.to_s)
      if (found.size > 0)
        found.first.destroy
      end
      success_response
    end

    def self.delete_all(association)
      association.destroy_all
      success_response
    end

    def self.get_user(uid)
      use_pooled_connection {
        User::Data.where(:uid => uid.to_s).first
      }
    end

    def self.success_response
      {
        :success => true
      }
    end

    def self.error_response(msg)
      {
        :success => false,
        :message => msg.to_s
      }
    end

  end
end
