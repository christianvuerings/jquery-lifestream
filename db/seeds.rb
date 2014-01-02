# Seed data is not meant for production servers.
# if they need new data, insert it via migrations instead.

filename = Rails.root.join("db", "developer-seed-data.sql")
input_file = File.open filename
sql = input_file.read

# comment out any ownership alterations (CLC-2989)
sql.gsub!(/(\n?)(ALTER TABLE .+ OWNER TO [\w]+;)/, "\\1-- \\2")

ActiveRecord::Base.connection.execute sql
Rails.logger.warn "developer-seed-data.sql loaded into db"
