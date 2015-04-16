class CreateWebcastPreferencesTable < ActiveRecord::Migration
  def change

    create_table :webcast_preferences do |t|
      t.integer  :year,                      null: false
      t.string   :term_cd,   limit: 1,       null: false
      t.integer  :ccn,                       null: false
      t.boolean  :opt_out,   default: false, null: false
      t.timestamps                           null: false
    end

    add_index(:webcast_preferences, [:year, :term_cd, :ccn], {name: 'webcast_preferences_main_index'})

  end
end
