namespace :migrations do

  # Run this task one time only, to shorten the number of digits on all the migrations.
  # This needs to be done outside of a db:migrate command because it manipulates the schema_migrations table.
  task :fix => :environment do
    sql = <<-SQL
      DROP TABLE IF EXISTS schema_migrations_backup;
      SELECT * INTO schema_migrations_backup FROM schema_migrations;
      UPDATE schema_migrations SET version = left(version, 14);
    SQL
    User::Data.connection.execute(sql)
  end

  # run this task only if you want to roll back to the old 16-digit db/migrate file naming system for some reason,
  # e.g. in the event of a production app server downgrade.
  task :unfix => :environment do
    sql = <<-SQL
      DROP TABLE IF EXISTS schema_migrations_fixed_backup;
      SELECT * INTO schema_migrations_fixed_backup FROM schema_migrations;
      DROP TABLE schema_migrations;
      SELECT * INTO schema_migrations FROM schema_migrations_backup;
    SQL
    User::Data.connection.execute(sql)
  end
end
