require 'json'
require 'rexml/document'

namespace :vcr do

  desc "Records new fixtures with ENV=testext"
  task :record do
    ENV["RAILS_ENV"] = "testext"
    ENV["freshen_vcr"] = "true"

    begin
      Rake::Task["spec"].invoke()
    rescue RuntimeError => e
      #Don't let spec failures stop json prettifying.
    end

    #Overwriting the single line json with human legible json.
    Dir.glob("#{Rails.root}/fixtures/pretty_vcr_recordings/*.json").each do |file|
      json_string = File.read(file)
      json = JSON.parse(json_string)
      pretty_json = JSON.pretty_generate(json)
      File.open(file, 'w') { |f| f.write(pretty_json) }
    end
  end

  desc "Pretties up the json result files"
  task :prettify do
    filter = ENV["REGEX_FILTER"]

    processed_dir = Rails.root.join("fixtures", "pretty_vcr_recordings")
    Dir.glob("#{Rails.root}/fixtures/pretty_vcr_recordings/*.json").each do |filename|
      if (!filter.blank?) && (filename =~ (/#{filter}/i)).nil?
        next
      end
      Rails.logger.info "Prettifying #{filename}"
      begin
        input_file = File.open filename
        content = input_file.read
        output_file = File.open(processed_dir.join(File.basename(input_file)), "w")

        # convert debug_json back to string representation
        json = JSON.parse(content)
        json["http_interactions"].each do |interaction|
          original_string = interaction["response"]["body"]["string"]
          if original_string && original_string.length >= 2
            begin
              interaction["response"]["body"]["debug_json"] = JSON.parse(original_string)
            rescue JSON::ParserError
              xml_doc = REXML::Document.new original_string
              interaction['response']['body']['debug_xml'] = ''
              REXML::Formatters::Pretty.new.write(xml_doc, interaction['response']['body']['debug_xml'])
            end
            interaction["response"]["body"]["string"] = ""
          end
        end

        Rails.logger.info "Pretty Output file = #{output_file.path}"
        output_file.write(JSON.pretty_generate(json))
      rescue JSON::ParserError
        Rails.logger.info "Got a JSON parse error prettiyfing #{filename}"
      ensure
        output_file.close
      end
    end
  end

  desc "Dumps out the requests that have been recorded in /fixtures/pretty_vcr_recordings/"
  task :list do
    recordings_hash = {}
    Dir.glob("#{Rails.root}/fixtures/pretty_vcr_recordings/*.json").each do |file|
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
