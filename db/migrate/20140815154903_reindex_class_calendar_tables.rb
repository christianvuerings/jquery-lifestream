class ReindexClassCalendarTables < ActiveRecord::Migration
  def up
    # first de-duplicate data
    sql = <<-SQL
      DELETE FROM class_calendar_log
      WHERE id IN (
        SELECT first_id FROM (
          SELECT job_id,year,term_cd,ccn,multi_entry_cd,min(id) AS first_id
          FROM class_calendar_log
          GROUP BY job_id,year,term_cd,ccn,multi_entry_cd
          HAVING COUNT(*) > 1 ) as duplicates
      )
    SQL
    execute sql

    sql = <<-SQL
      DELETE FROM class_calendar_queue
      WHERE id IN (
        SELECT first_id FROM (
          SELECT year,term_cd,ccn,multi_entry_cd,min(id) AS first_id
          FROM class_calendar_queue
          GROUP BY year,term_cd,ccn,multi_entry_cd
          HAVING COUNT(*) > 1 ) as duplicates
      )
    SQL
    execute sql

    remove_index(:class_calendar_queue, {name: 'class_calendar_queue_main_index'})
    add_index(:class_calendar_queue, [:year, :term_cd, :ccn, :multi_entry_cd], {name: 'class_calendar_queue_unique_index', unique: true})

    remove_index(:class_calendar_log, {name: 'class_calendar_log_main_index'})
    remove_index(:class_calendar_log, :job_id)
    add_index(:class_calendar_log, [:year, :term_cd, :ccn, :multi_entry_cd, :job_id], {name: 'class_calendar_log_unique_index', unique: true})
  end

  def down
    remove_index(:class_calendar_queue, {name: 'class_calendar_queue_unique_index'})
    add_index(:class_calendar_queue, [:year, :term_cd, :ccn, :multi_entry_cd], {name: 'class_calendar_queue_main_index'})

    remove_index(:class_calendar_log, {name: 'class_calendar_log_unique_index'})
    add_index(:class_calendar_log, [:year, :term_cd, :ccn, :multi_entry_cd], {name: 'class_calendar_log_main_index'})
    add_index(:class_calendar_log, :job_id)
  end
end
