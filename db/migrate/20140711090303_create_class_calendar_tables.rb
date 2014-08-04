class CreateClassCalendarTables < ActiveRecord::Migration
  def change
    create_table :class_calendar_users do |t|
      t.string :uid
      t.string :alternate_email
    end

    create_table :class_calendar_queue do |t|
      t.integer :year
      t.string :term_cd
      t.integer :ccn
      t.string :multi_entry_cd
      t.text :event_data
      t.timestamps
    end

    add_index(:class_calendar_queue, [:year, :term_cd, :ccn, :multi_entry_cd], {name: 'class_calendar_queue_main_index'})

    create_table :class_calendar_log do |t|
      t.integer :year
      t.string :term_cd
      t.integer :ccn
      t.string :multi_entry_cd
      t.integer :job_id
      t.text :event_data
      t.string :event_id
      t.timestamp :processed_at
      t.string :response_status
      t.text :response_body
      t.boolean :has_error
      t.timestamps
    end

    add_index(:class_calendar_log, [:year, :term_cd, :ccn, :multi_entry_cd], {name: 'class_calendar_log_main_index'})
    add_index(:class_calendar_log, :job_id)
    add_index(:class_calendar_log, :event_id)

    create_table :class_calendar_jobs do |t|
      t.datetime :process_start_time
      t.datetime :process_end_time
      t.integer :total_entry_count
      t.integer :error_count
    end

  end
end
