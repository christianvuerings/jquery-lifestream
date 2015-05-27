module Canvas
  module ExternalAppConfigurations
    extend self
    include ClassLogger

    def lti_app_definitions
      {
        'site_creation' => {
          xml_name: 'lti_site_creation',
          app_name: 'Create a Site',
          account: main_account_id
        },
        'site_mailing_lists' => {
          xml_name: 'lti_site_mailing_lists',
          app_name: 'Site Mailing Lists',
          account: Settings.features.manage_site_mailing_lists ? admin_tools_account_id : nil
        },
        'rosters' => {
          xml_name: 'lti_roster_photos',
          app_name: 'Roster Photos',
          account: official_courses_account_id
        },
        'user_provision' => {
          xml_name: 'lti_user_provision',
          app_name: 'User Provisioning',
          account: main_account_id
        },
        'course_add_user' => {
          xml_name: 'lti_course_add_user',
          app_name: 'Find a Person to Add',
          account: main_account_id
        },
        'course_mediacasts' => {
          xml_name: 'lti_course_mediacasts',
          app_name: 'Webcasts',
          account: main_account_id
        },
        'course_manage_official_sections' => {
          xml_name: 'lti_course_manage_official_sections',
          app_name: 'Official Sections',
          account: Settings.features.course_manage_official_sections ? official_courses_account_id : nil
        },
        'course_grade_export' => {
          xml_name: 'lti_course_grade_export',
          app_name: 'Download E-Grades',
          account: official_courses_account_id
        }
      }
    end

    def main_account_id
      Settings.canvas_proxy.account_id
    end

    def admin_tools_account_id
      Settings.canvas_proxy.admin_tools_account_id
    end

    def official_courses_account_id
      Settings.canvas_proxy.official_courses_account_id
    end

    def app_code_to_xml_name(app_code)
      lti_app_definitions[app_code] && lti_app_definitions[app_code][:xml_name]
    end

    def xml_name_to_app_code(xml_name)
      lti_app_definitions.each do |app_code, definition|
        return app_code if definition[:xml_name] == xml_name
      end
      nil
    end

    def parse_host_and_code_from_launch_url(launch_url)
      # The interesting app URLs look like: "https://cc-dev.example.com/canvas/embedded/rosters".
      url_regex = %r{(?<app_host>http[s]?://.+)/canvas/embedded/(?<app_code>.+)}
      url_regex.match(launch_url)
    end

    def launch_url_for_host_and_code(app_host, app_code)
      "#{app_host}/canvas/embedded/#{app_code}"
    end

    def refresh_accounts
      [main_account_id, official_courses_account_id]
    end

  end
end
