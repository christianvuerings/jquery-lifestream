task :travis do
  # Replace with
  # ["rspec spec", "rake jasmine:ci"].each do |cmd|
  # when we have the rspec tests working
  ["rake jasmine:ci"].each do |cmd|
    puts "Starting to run #{cmd}..."
    system("export DISPLAY=:99.0 && bundle exec #{cmd}")
    raise "#{cmd} failed!" unless $?.exitstatus == 0
  end
end
