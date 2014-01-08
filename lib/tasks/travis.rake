task :travis do

  puts "Starting JSHint"
  system ("jshint .")
  raise "JSHint failed!" unless $?.exitstatus == 0

end
