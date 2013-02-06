def in_memory_database?
  Rails.env == "test" and !(Rails.configuration.database_configuration['test']['database'] =~ /\:memory\:/).nil?
end

if in_memory_database?
  load "#{Rails.root}/db/schema.rb"
end