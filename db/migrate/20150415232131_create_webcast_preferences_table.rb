class CreateWebcastPreferencesTable < ActiveRecord::Migration
  def change

    create_table :webcast_preferences do |t|
      t.integer :year
      t.string :term_cd
      t.integer :ccn
      t.boolean :opt_out
      t.timestamps
    end

    add_index(:webcast_preferences, [:year, :term_cd, :ccn], {name: 'webcast_preferences_main_index'})

  end
end
