class WebcastPreferencesUniqueIndex < ActiveRecord::Migration
  def change
    remove_index(:webcast_preferences, {name: 'webcast_preferences_main_index'})
    add_index(:webcast_preferences, [:year, :term_cd, :ccn], {name: 'webcast_preferences_unique_index', unique: true})
  end
end
