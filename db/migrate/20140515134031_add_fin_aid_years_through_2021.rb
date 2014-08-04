class AddFinAidYearsThrough2021 < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        # Admissions letters are sent on the day after the Spring Recess holiday.
        Finaid::FinAidYear.create(current_year: 2017, upcoming_start_date: Date.new(2017, 4, 1))
        Finaid::FinAidYear.create(current_year: 2018, upcoming_start_date: Date.new(2018, 3, 31))
        Finaid::FinAidYear.create(current_year: 2019, upcoming_start_date: Date.new(2019, 3, 30))
        Finaid::FinAidYear.create(current_year: 2020, upcoming_start_date: Date.new(2020, 3, 28))
        Finaid::FinAidYear.create(current_year: 2021, upcoming_start_date: Date.new(2021, 3, 27))
      end
      dir.down do
        Finaid::FinAidYear.delete_all('current_year in (2017, 2018, 2019, 2020, 2021)')
      end
    end
  end
end
