class CreateFinAidYears < ActiveRecord::Migration
  def change
    create_table :fin_aid_years do |t|
      t.integer :current_year, null:false
      t.date :upcoming_start_date, null:false
      t.timestamps
    end

    change_table :fin_aid_years do |t|
      t.index [:current_year], unique: true
    end

    reversible do |dir|
      dir.up do
        # Admissions letters are sent on the day after the Spring Recess holiday.
        Finaid::FinAidYear.create(current_year: 2013, upcoming_start_date: Date.new(2014, 3, 29))
        Finaid::FinAidYear.create(current_year: 2014, upcoming_start_date: Date.new(2015, 3, 28))
        Finaid::FinAidYear.create(current_year: 2015, upcoming_start_date: Date.new(2016, 3, 26))
      end
      dir.down do
        # All rows should be dropped.
      end
    end


  end
end
