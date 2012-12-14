require 'json'

namespace :vcr do

  desc "Records new fixtures with ENV=testext & pretty-print json result files"
  task :record do
    ENV["RAILS_ENV"] = "testext"
    ENV["freshen_vcr"] = "true"

    begin
      Rake::Task["spec"].invoke()
    rescue RuntimeError => e
      #Don't let spec failures stop json prettifying.
    end

    Dir.glob("#{Rails.root}/fixtures/fakeable_proxy_data/*.json").each do |file|
      json_string = File.read(file)
      json = JSON.parse(json_string)
      json["http_interactions"].each do |interaction|
        body_string = interaction["response"]["body"]["string"]
        if body_string.length >= 2
          interaction["response"]["body"]["debug_json"] = JSON.parse(body_string)
        end
      end
      pretty_json =  JSON.pretty_generate(json)
      File.open(file, 'w') { |f| f.write(pretty_json)}
    end
  end

  desc "Dumps out the requests that have been recorded in /fixtures/fakeable_proxy/"
  task :list do
    recordings_hash = {}
    Dir.glob("#{Rails.root}/fixtures/fakeable_proxy_data/*.json").each do |file|
      json_string = File.read(file)
      json = JSON.parse(json_string)
      json["http_interactions"].each do |interaction|
        type = interaction["request"]["method"]
        recordings_hash[type.upcase.to_sym] ||= []
        recordings_hash[type.upcase.to_sym] << interaction["request"]["uri"]
      end
    end
    puts JSON.pretty_generate(recordings_hash)
  end
end
