Rails.application.config.after_initialize do

  # Go through fixtures/pretty_vcr_recordings/*.json and substitute current datetime values where we find tokens. Save
  # the processed files in fixtures/vcr_cassettes for use by FakeableProxy.

  # midnight on the current day
  today = Time.zone.today.to_time_in_current_zone.to_datetime
  end_of_week = today.sunday
  next_week = end_of_week.advance(days: 2)
  far_future = next_week.advance(days: 7)

  # Google tasks store due dates as zero-hour Z-time
  end_of_week_utc = today.sunday.to_date.to_datetime
  next_week_utc = end_of_week_utc.advance(days: 2)
  far_future_utc = next_week_utc.advance(days: 7)

  substitutions = {
      ":::SEVEN_MONTHS_AGO:::" => today.advance(:months => -7).rfc3339,
      ":::FIVE_MONTHS_AGO:::" => today.advance(:months => -5).rfc3339,
      ":::TWENTY_SEVEN_DAYS_AGO:::" => today.advance(:days => -27).rfc3339,
      ":::TWO_WEEKS_AGO:::" => today.advance(:weeks => -2).rfc3339,
      ":::DAY_BEFORE_YESTERDAY:::" => today.advance(:days => -2).rfc3339,
      ":::YESTERDAY:::" => today.advance(:days => -1).rfc3339,
      ":::TWO_DAYS_AGO_MIDNIGHT_PST:::" => today.advance(:days => -1, :minutes => -1).rfc3339,
      ":::TODAY_MIDNIGHT_PST:::" => today.rfc3339,
      ":::TOMORROW_MIDNIGHT_PST:::" => today.advance(:days => 1).rfc3339,
      ":::TODAY_AT_TEA_TIME:::" => today.advance(:hours => 15, :minutes => 47, :seconds => 13).rfc3339,
      ":::SIX_DAYS_HENCE:::" => today.advance(:days => 6).rfc3339,
      ":::ONE_MONTH_HENCE:::" => today.advance(:months => 1).rfc3339,
      ":::FIVE_MONTHS_HENCE:::" => today.advance(:months => 5).rfc3339,
      ":::SEVEN_MONTHS_HENCE:::" => today.advance(:months => 7).rfc3339,
      ":::TODAY_EARLY:::" => today.advance(:hours => 0, :minutes => 05, :seconds => 00).rfc3339,
      ":::TODAY_LATE:::" => today.advance(:hours => 23, :minutes => 59, :seconds => 59).rfc3339,
      ":::TODAY_NINE:::" => today.advance(:hours => 9, :minutes => 00, :seconds => 00).rfc3339,
      ":::TODAY_TEN:::" => today.advance(:hours => 10, :minutes => 00, :seconds => 00).rfc3339,
      ":::TODAY_LUNCHTIME:::" => today.advance(:hours => 12, :minutes => 30, :seconds => 00).rfc3339,
      ":::TODAY_AFTER_LUNCH:::" => today.advance(:hours => 14, :minutes => 00, :seconds => 00).rfc3339,
      ":::TODAY_THREE_THIRTY:::" => today.advance(:hours => 15, :minutes => 30, :seconds => 00).rfc3339,
      ":::TODAY_FOUR_THIRTY:::" => today.advance(:hours => 16, :minutes => 30, :seconds => 00).rfc3339,
      ":::LATER_IN_WEEK:::" => end_of_week.rfc3339,
      ":::NEXT_WEEK:::" => next_week.rfc3339,
      ":::FAR_FUTURE:::" => far_future.rfc3339,
      ":::UTC_LATER_IN_WEEK:::" => end_of_week_utc.strftime('%FT%T.000Z'),
      ":::UTC_NEXT_WEEK:::" => next_week_utc.strftime('%FT%T.000Z'),
      ":::UTC_FAR_FUTURE:::" => far_future_utc.strftime('%FT%T.000Z'),
      ":::TODAY:::" => today.rfc3339,
      ":::TOMORROW:::" => today.advance(days: 1).rfc3339,
      ":::TOMORROW_NO_TIME:::" => today.advance(days: 1).strftime("%Y-%m-%d"),
      ":::DAY_AFTER_TOMORROW:::" => today.advance(days: 2).rfc3339,
  }

  Rails.logger.debug "Timeshifter: Today = #{today}; epoch = #{today.to_i}"
  Rails.logger.debug "Timeshifter: Substitutions = #{substitutions.inspect}"

  processed_dir = Rails.root.join("fixtures", "vcr_cassettes")

  Dir.glob("#{Rails.root}/fixtures/pretty_vcr_recordings/*.json").each do |filename|
    Rails.logger.debug "Timeshifter: Processing #{filename}"
    begin
      input_file = File.open filename
      content = input_file.read
      output_file = File.open(processed_dir.join(File.basename(input_file)), "w")

      # substitute tokens with formatted date values
      substitutions.each { |k, v| content.gsub!(k, v) }

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
