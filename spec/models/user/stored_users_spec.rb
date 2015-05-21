require 'spec_helper'

describe User::StoredUsers do

  let(:owner_uid) { '1234' }
  let(:uid_to_store) { '100' }
  let(:uid_to_delete) { '101' }
  let(:stored_uid) { '568' }

  let(:success_response) do
    {
      :success => true
    }
  end

  let(:already_stored_error) do
    {
      :success => false,
      :message => "UID #{uid_to_store} is already stored."
    }
  end

  let(:not_found_error) do
    {
      :success => false,
      :message => "Could not find user #{owner_uid}."
    }
  end

  let(:fake_stored_uid_entries) do
    {
      :saved => [
        {
          :stored_uid => stored_uid
        }
      ],
      :recent => [
        {
          :stored_uid => stored_uid
        }
      ]
    }
  end

  let(:fake_ldap_user) do
    [
      {
        'ldap_uid' => stored_uid
      }
    ]
  end

  describe '#get' do

    it 'should return list of users stored by the current user' do
      stub_model = double
      saved_uids_stub = double
      recent_uids_stub = double

      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(stub_model)
      stub_model.should_receive(:saved_uids).and_return(saved_uids_stub)
      stub_model.should_receive(:recent_uids).and_return(recent_uids_stub)

      saved_uids_stub.should_receive(:order).with(:created_at).and_return(saved_uids_stub)
      saved_uids_stub.should_receive(:reverse_order).and_return(fake_stored_uid_entries[:saved])

      recent_uids_stub.should_receive(:order).with(:created_at).and_return(recent_uids_stub)
      recent_uids_stub.should_receive(:reverse_order).and_return(fake_stored_uid_entries[:recent])

      User::SearchUsersByUid.should_receive(:new).with({ ids: [stored_uid, stored_uid] }).and_return(stub_model)
      stub_model.should_receive(:search_users_by_uid_batch).and_return(fake_ldap_user)

      users = User::StoredUsers.get(owner_uid)

      expect(users[:saved][0]['ldap_uid']).to eq stored_uid
      expect(users[:recent][0]['ldap_uid']).to eq stored_uid
    end

    it 'should report whether recent uids are saved' do
      saved_uid = random_id
      unsaved_uid = random_id
      User::Data.create(uid: owner_uid)
      User::Data.create(uid: saved_uid)
      User::Data.create(uid: unsaved_uid)
      allow_any_instance_of(User::SearchUsersByUid).to receive(:search_users_by_uid_batch).
          and_return [{'ldap_uid' => owner_uid}, {'ldap_uid' => saved_uid}, {'ldap_uid' => unsaved_uid}]

      User::StoredUsers.store_saved_uid(owner_uid, saved_uid)
      User::StoredUsers.store_recent_uid(owner_uid, saved_uid)
      User::StoredUsers.store_recent_uid(owner_uid, unsaved_uid)

      users = User::StoredUsers.get(owner_uid)
      expect(users[:recent]).to include({'ldap_uid' => saved_uid, 'saved' => true})
      expect(users[:recent]).to include({'ldap_uid' => unsaved_uid, 'saved' => false})
    end

  end

  describe '#store_saved_uid' do

    it 'should store uid successfully if uid is not already stored and current user exists' do
      stub_model = double
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(stub_model)
      stub_model.should_receive(:saved_uids).and_return(stub_model)
      stub_model.should_receive(:where).with({ :stored_uid => uid_to_store }).and_return([])
      stub_model.should_receive(:create).with({ :stored_uid => uid_to_store })

      response = User::StoredUsers.store_saved_uid(owner_uid, uid_to_store)
      expect(response).to eq success_response
    end

    it 'should return error if owner_uid does not exist' do
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(nil)

      response = User::StoredUsers.store_saved_uid(owner_uid, uid_to_store)
      expect(response).to eq not_found_error
    end

    it 'should return error if uid_to_store is already stored' do
      stub_model = double
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(stub_model)
      stub_model.should_receive(:saved_uids).and_return(stub_model)
      stub_model.should_receive(:where).with({ :stored_uid => uid_to_store }).and_return([1, 2])

      response = User::StoredUsers.store_saved_uid(owner_uid, uid_to_store)
      expect(response).to eq already_stored_error
    end

  end

  describe '#store_recent_uid' do

    it 'should store uid successfully if uid is not already stored and current user exists' do
      stub_model = double
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(stub_model)
      stub_model.should_receive(:recent_uids).and_return(stub_model)
      stub_model.should_receive(:where).with({ :stored_uid => uid_to_store }).and_return([])
      stub_model.should_receive(:create).with({ :stored_uid => uid_to_store })

      response = User::StoredUsers.store_recent_uid(owner_uid, uid_to_store)
      expect(response).to eq success_response
    end

    it 'should limit number of uids per owner, removing oldest first' do
      owner = User::Data.create(uid: owner_uid)
      uid = uid_to_store
      User::RecentUid::MAX_PER_OWNER_ID.times do
        User::StoredUsers.store_recent_uid(owner_uid, uid)
        uid = uid.next
      end

      all_recent = owner.recent_uids.order(:created_at).all
      expect(all_recent.count).to eq User::RecentUid::MAX_PER_OWNER_ID
      oldest, second_oldest = all_recent[0,2]

      User::StoredUsers.store_recent_uid(owner_uid, uid.next)

      expect(owner.recent_uids.count).to eq User::RecentUid::MAX_PER_OWNER_ID
      expect(owner.recent_uids.find_by id: oldest.id).to be_blank
      expect(owner.recent_uids.find_by id: second_oldest.id).to be_present
    end

    it 'should return error if owner_uid does not exist' do
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(nil)

      response = User::StoredUsers.store_recent_uid(owner_uid, uid_to_store)
      expect(response).to eq not_found_error
    end

    it 'should return error if uid_to_store is already stored' do
      stub_model = double
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(stub_model)
      stub_model.should_receive(:recent_uids).and_return(stub_model)
      stub_model.should_receive(:where).with({ :stored_uid => uid_to_store }).and_return([1, 2])

      response = User::StoredUsers.store_recent_uid(owner_uid, uid_to_store)
      expect(response).to eq already_stored_error
    end

  end

  describe '#delete_saved_uid' do

    it 'should delete uid successfully' do
      stub_model = double
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(stub_model)
      stub_model.should_receive(:saved_uids).and_return(stub_model)
      stub_model.should_receive(:where).with({ :stored_uid => uid_to_delete }).and_return(stub_model)
      stub_model.should_receive(:size).and_return(1)
      stub_model.should_receive(:first).and_return(stub_model)
      stub_model.should_receive(:destroy)

      response = User::StoredUsers.delete_saved_uid(owner_uid, uid_to_delete)
      expect(response).to eq success_response
    end

    it 'should still return success if uid_to_delete is already absent' do
      stub_model = double
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(stub_model)
      stub_model.should_receive(:saved_uids).and_return(stub_model)
      stub_model.should_receive(:where).with({ :stored_uid => uid_to_delete }).and_return(stub_model)
      stub_model.should_receive(:size).and_return(0)

      response = User::StoredUsers.delete_saved_uid(owner_uid, uid_to_delete)
      expect(response).to eq success_response
    end

    it 'should return error if owner_uid does not exist' do
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(nil)

      response = User::StoredUsers.delete_saved_uid(owner_uid, uid_to_delete)
      expect(response).to eq not_found_error
    end

  end

  describe '#delete_recent_uid' do

    it 'should delete uid successfully' do
      stub_model = double
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(stub_model)
      stub_model.should_receive(:recent_uids).and_return(stub_model)
      stub_model.should_receive(:where).with({ :stored_uid => uid_to_delete }).and_return(stub_model)
      stub_model.should_receive(:size).and_return(1)
      stub_model.should_receive(:first).and_return(stub_model)
      stub_model.should_receive(:destroy)

      response = User::StoredUsers.delete_recent_uid(owner_uid, uid_to_delete)
      expect(response).to eq success_response
    end

    it 'should still return success if uid_to_delete is already absent' do
      stub_model = double
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(stub_model)
      stub_model.should_receive(:recent_uids).and_return(stub_model)
      stub_model.should_receive(:where).with({ :stored_uid => uid_to_delete }).and_return(stub_model)
      stub_model.should_receive(:size).and_return(0)

      response = User::StoredUsers.delete_recent_uid(owner_uid, uid_to_delete)
      expect(response).to eq success_response
    end

    it 'should return error if owner_uid does not exist' do
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(nil)

      response = User::StoredUsers.delete_recent_uid(owner_uid, uid_to_delete)
      expect(response).to eq not_found_error
    end

  end

  describe '#delete_all_recent' do

    it 'should delete recent uids successfully' do
      stub_model = double
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(stub_model)
      stub_model.should_receive(:recent_uids).and_return(stub_model)
      stub_model.should_receive(:destroy_all)

      response = User::StoredUsers.delete_all_recent(owner_uid)
      expect(response).to eq success_response
    end

    it 'should return error if owner_uid does not exist' do
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(nil)

      response = User::StoredUsers.delete_all_recent(owner_uid)
      expect(response).to eq not_found_error
    end

  end


  describe '#delete_all_saved' do

    it 'should delete saved uids successfully' do
      stub_model = double
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(stub_model)
      stub_model.should_receive(:saved_uids).and_return(stub_model)
      stub_model.should_receive(:destroy_all)

      response = User::StoredUsers.delete_all_saved(owner_uid)
      expect(response).to eq success_response
    end

    it 'should return error if owner_uid does not exist' do
      User::StoredUsers.should_receive(:get_user).with(owner_uid).and_return(nil)

      response = User::StoredUsers.delete_all_saved(owner_uid)
      expect(response).to eq not_found_error
    end

  end

end
