Rails.application.config.after_initialize do

  # Go through fixtures/pretty_vcr_recordings/*.json and substitute current datetime values where we find tokens. Save
  # the processed files in fixtures/vcr_cassettes for use by FakeableProxy.

  # midnight on the current day
  today = Date.today.to_time_in_current_zone.to_datetime

  substitutions = {
      ":::TWO_DAYS_AGO_PST:::" => today.advance(:days => -1, :minutes => -1).rfc3339,
      ":::TODAY_AT_TEA_TIME:::" => today.advance(:hours => 15, :minutes => 47, :seconds => 13).rfc3339,
      ":::SIX_DAYS_HENCE:::" => today.advance(:days => 6).rfc3339,
      ":::EIGHT_DAYS_HENCE:::" => today.advance(:days => 8).rfc3339,
  }

  Rails.logger.info "Timeshifter: Today = #{today}; epoch = #{today.to_i}"

  processed_dir = Rails.root.join("fixtures", "vcr_cassettes")

  Dir.glob("#{Rails.root}/fixtures/pretty_vcr_recordings/*.json").each do |filename|
    Rails.logger.info "Timeshifter: Processing #{filename}"
    begin
      input_file = File.open filename
      content = input_file.read
      output_file = File.open(processed_dir.join(File.basename(input_file)), "w")

      # substitute tokens with formatted date values
      substitutions.each { |k, v| content.gsub!(k, v) }

      # convert debug_json back to string representation
      json = JSON.parse(content)
      json["http_interactions"].each do |interaction|
        interaction["response"]["body"]["string"] = MultiJson.dump(interaction["response"]["body"]["debug_json"])
      end

      Rails.logger.info "Timeshifter: Output file = #{output_file.path}"
      output_file.write(JSON.pretty_generate(json))
    rescue JSON::ParserError
      Rails.logger.info "No valid JSON to parse in #{filename}"
    ensure
      output_file.close
    end
  end

end
