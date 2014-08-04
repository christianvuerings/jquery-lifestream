class CreateUserVisits < ActiveRecord::Migration
  def up
    create_table :user_visits, :id => false do |t|
      t.string :uid, :null => false
      t.timestamp :last_visit_at, :null => false
    end

    change_table :user_visits do |t|
      t.index [:uid], :unique => true
      t.index [:last_visit_at]
    end
  end

  def down
    drop_table :user_visits
  end
end
