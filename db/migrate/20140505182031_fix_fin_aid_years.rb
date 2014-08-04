class FixFinAidYears < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        Finaid::FinAidYear.destroy_all
        # Admissions letters are sent on the day after the Spring Recess holiday.
        Finaid::FinAidYear.create(current_year: 2014, upcoming_start_date: Date.new(2014, 3, 29))
        Finaid::FinAidYear.create(current_year: 2015, upcoming_start_date: Date.new(2015, 3, 28))
        Finaid::FinAidYear.create(current_year: 2016, upcoming_start_date: Date.new(2016, 3, 26))
      end
      dir.down do
      end
    end
  end
end
