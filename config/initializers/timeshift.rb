Rails.application.config.after_initialize do

  if Settings.application.fake_proxies_enabled
    # Go through fixtures/pretty_vcr_recordings/*.json and substitute current datetime values where we find tokens. Save
    # the processed files in fixtures/vcr_cassettes for use by FakeableProxy.

    processed_dir = Rails.root.join("fixtures", "vcr_cassettes")

    Dir.glob("#{Rails.root}/fixtures/pretty_vcr_recordings/*.json").each do |filename|
      Rails.logger.debug "Timeshifter: Processing #{filename}"
      begin
        input_file = File.open filename
        content = input_file.read
        output_file = File.open(processed_dir.join(File.basename(input_file)), "w")

        Timeshifter.process content

        # convert debug_json back to string representation
        json = JSON.parse(content)
        json["http_interactions"].each do |interaction|
          if interaction["response"]["body"]["debug_xml"]
            interaction["response"]["body"]["string"] = interaction["response"]["body"]["debug_xml"]
          else
            interaction["response"]["body"]["string"] = MultiJson.dump(interaction["response"]["body"]["debug_json"])
          end
        end

        Rails.logger.debug "Timeshifter: Output file = #{output_file.path}"
        output_file.write(JSON.pretty_generate(json))
      rescue JSON::ParserError
        Rails.logger.warn "No valid JSON to parse in #{filename}"
      ensure
        output_file.close
      end
    end
  end

end
