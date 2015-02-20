class AddStoredUidTableIndexesAndRename < ActiveRecord::Migration

  def up

    change_table :saved_uids do |t|
      t.rename :owner_uid, :owner_id
    end

    add_index(:saved_uids, [:owner_id], {name: 'saved_uids_index'})

    change_table :recent_uids do |t|
      t.rename :owner_uid, :owner_id
    end

    add_index(:recent_uids, [:owner_id], {name: 'recent_uids_index'})

  end

  def down

    change_table :saved_uids do |t|
      t.rename :owner_id, :owner_uid
    end

    remove_index(:saved_uids, {name: 'saved_uids_index'})

    change_table :recent_uids do |t|
      t.rename :owner_id, :owner_uid
    end

    remove_index(:recent_uids, {name: 'recent_uids_index'})

  end

end
