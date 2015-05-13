module Webcast
  class Recordings < Proxy

    def get_json_path
      'webcast.json'
    end

    def request_internal
      return {} unless Settings.features.videos

      recordings = {
        courses: {}
      }
      get_json_data['courses'].each do |course|
        year = course['year']
        semester = course['semester']
        ccn = course['ccn']
        if year && semester && ccn
          key = Webcast::CourseMedia.id_per_ccn(year, semester, course['ccn'])
          recordings[:courses][key] = {
            audio_only: course['audioOnly'],
            audio_rss: course['audioRSS'].to_s,
            recordings: course['recordings'],
            itunes_audio: course['iTunesAudio'].to_s,
            itunes_video: course['iTunesVideo'].to_s
          }
        end
      end
      recordings
    end

  end
end
