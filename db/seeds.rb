# Seed data is not meant for production servers.
# if they need new data, insert it via migrations instead.

filename = Rails.root.join("db", "developer-seed-data.sql")
input_file = File.open filename
sql = input_file.read
ActiveRecord::Base.connection.execute sql
Rails.logger.warn "developer-seed-data.sql loaded into db"
