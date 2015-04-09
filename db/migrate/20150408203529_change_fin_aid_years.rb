class ChangeFinAidYears < ActiveRecord::Migration
  reversible do |dir|
    dir.up do
      if (row = Finaid::FinAidYear.find_by(current_year: 2015))
        row.update_attribute(:upcoming_start_date, Date.new(2015, 4, 25))
      end
      Finaid::FinAidYear.where('current_year > 2015').each do |row|
        row.update_attribute(:upcoming_start_date, Date.new(row.current_year, 5, 1))
      end
    end
    dir.down do
      # Downgrades should be managed through ccadmin.
    end
  end
end
