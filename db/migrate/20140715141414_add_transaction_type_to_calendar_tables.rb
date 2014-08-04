class AddTransactionTypeToCalendarTables < ActiveRecord::Migration

  def change
    add_column(:class_calendar_queue, :transaction_type, :string, :default => 'C')
    add_column(:class_calendar_log, :transaction_type, :string, :default => 'C')
  end

end
