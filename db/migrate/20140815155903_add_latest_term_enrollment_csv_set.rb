class AddLatestTermEnrollmentCsvSet < ActiveRecord::Migration
  def change
    add_column(:canvas_synchronization, :latest_term_enrollment_csv_set, :datetime)
  end
end
