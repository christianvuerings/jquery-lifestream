module MyActivities
  class Webcasts
    include DatedFeed

    def self.append!(uid, activities)
      term_code = get_current_term_code
      courses_by_ccn = get_courses_by_ccn(uid, term_code)
      webcast_feed = Webcast::Recordings.new.get
      return unless webcast_feed[:courses]

      webcast_feed[:courses].each do |course_code, webcast_course|
        next unless course_code.start_with?(term_code) && webcast_course[:recordings]
        # Zero-pad CCNs from the Webcasts feed to match campus data.
        ccn = course_code.sub("#{term_code}-", '').rjust(5, '0')
        if (campus_course = courses_by_ccn[ccn])
          activity = course_attributes(campus_course, uid)
          course_url = MyAcademics::AcademicsModule.class_to_url campus_course
          each_recent_recording(webcast_course) do |recording|
            activities << activity.merge(recording_attributes(recording, course_url))
          end
        end
      end
    end

    def self.course_attributes(campus_course, uid)
      english_term = Berkeley::TermCodes.to_english(campus_course[:term_yr], campus_course[:term_cd])
      {
        emitter: 'Webcasts',
        id: '',
        linkText: 'View webcast',
        source: campus_course[:course_code],
        summary: "A new webcast recording for your #{english_term} course, #{campus_course[:name]}, is now available.",
        type: 'webcast',
        title: 'Webcast Available',
        user_id: uid
      }
    end

    def self.each_recent_recording(webcast_course)
      webcast_course[:recordings].each do |recording|
        next unless recording['recordingStartUTC'].present? && (start_time = DateTime.parse recording['recordingStartUTC'])
        if start_time.to_i >= MyActivities::Merged.cutoff_date
          yield recording.merge('startTime' => start_time)
        end
      end
    end

    def self.get_courses_by_ccn(uid, term_code)
      courses = {}
      all_courses = CampusOracle::UserCourses::All.new(user_id: uid).get_all_campus_courses
      if (current_term_courses = all_courses[term_code])
        current_term_courses.each do |course|
          course[:sections].each { |section| courses[section[:ccn]] = course }
        end
      end
      courses
    end

    def self.get_current_term_code
      current_term = Berkeley::Terms.fetch.current
      "#{current_term.year}-#{current_term.code}"
    end

    def self.recording_attributes(recording, course_url)
      url = course_url.dup
      url << '?' << {video: recording['youTubeId']}.to_param if recording['youTubeId']
      {
        date: format_date(recording['startTime']),
        sourceUrl: url,
        url: url
      }
    end

  end
end
