class AlterWebcastPreferencesTable < ActiveRecord::Migration
  def change

    remove_index(:webcast_preferences, {name: 'webcast_preferences_unique_index'})
    remove_index(:webcast_preferences, :year)
    remove_index(:webcast_preferences, :term_cd)
    remove_index(:webcast_preferences, :ccn)
    drop_table :webcast_preferences

    create_table :webcast_course_site_log do |t|
      t.integer     :canvas_course_site_id,     null: false
      t.timestamp   :webcast_tool_unhidden_at,  null: false
      t.timestamps                              null: false
    end

    add_index(:webcast_course_site_log, [:canvas_course_site_id], {name: 'webcast_course_site_log_unique_index', unique: true})

  end
end
