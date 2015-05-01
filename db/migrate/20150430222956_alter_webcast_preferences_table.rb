class AlterWebcastPreferencesTable < ActiveRecord::Migration

  def up
    remove_index(:webcast_preferences, {column: [:year, :term_cd, :ccn], name: 'webcast_preferences_unique_index', unique: true})

    drop_table :webcast_preferences, force: :cascade

    create_table :webcast_course_site_log do |t|
      t.integer     :canvas_course_site_id,     null: false
      t.timestamp   :webcast_tool_unhidden_at,  null: false
      t.timestamps                              null: false
    end
    add_index(:webcast_course_site_log, [:canvas_course_site_id], {name: 'webcast_course_site_log_unique_index', unique: true})
  end

  def down
    drop_table :webcast_course_site_log, force: :cascade if ActiveRecord::Base.connection.table_exists? :webcast_course_site_log

    create_table :webcast_preferences do |t|
      t.integer  :year,                      null: false
      t.string   :term_cd,   limit: 1,       null: false
      t.integer  :ccn,                       null: false
      t.boolean  :opt_out,   default: false, null: false
      t.timestamps                           null: false
    end
    add_index(:webcast_preferences, [:year, :term_cd, :ccn], {name: 'webcast_preferences_unique_index', unique: true})
  end

end
