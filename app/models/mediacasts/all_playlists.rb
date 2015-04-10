module Mediacasts
  class AllPlaylists < Proxy

    def initialize(options = {})
      super(options)
    end

    def get_json_path
      'webcast.json'
    end

    def request_internal
      return {} unless Settings.features.videos

      data = get_json_data
      recordings = {
        courses: {}
      }
      data['courses'].each do |course|
        if course['year'] && course['semester'] && course['deptName'] && course['catalogId']
          key = Mediacasts::CourseMedia.course_id(course['year'], course['semester'], course['deptName'], course['catalogId'])
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

