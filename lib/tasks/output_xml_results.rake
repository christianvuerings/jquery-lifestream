namespace :spec do
  if %w(test testext).include? Rails.env
    desc "Runs rake spec, but pipes the output to xml using the rspec_junit_formatter gem"
    RSpec::Core::RakeTask.new(:xml) do |t|
      # Because most of us aren't perfect, but we'd still want the out pipe to show us why.
      t.fail_on_error = false
      t.rspec_opts = ['--format documentation --format RspecJunitFormatter --out coverage/rspec.xml']
    end
  end
end
