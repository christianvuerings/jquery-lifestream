require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'csv'
require 'json'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/api_my_status_page'
require_relative 'pages/api_my_academics_page_semesters'
require_relative 'pages/my_dashboard_my_classes_card'

describe 'The Dashboard My Classes card', :testui => true do

  if ENV["UI_TEST"]

    include ClassLogger

    begin

      driver = WebDriverUtils.launch_browser
      test_users = UserUtils.load_test_users
      test_output = UserUtils.initialize_output_csv self
      testable_users = []

      CSV.open(test_output, 'wb') do |user_info_csv|
        user_info_csv << ['UID', 'Enrolled', 'Course Sites', 'Teaching', 'Teaching Sites', 'Other Sites']
      end

      test_users.each do |user|
        if user['classes']
          uid = user['uid'].to_s
          logger.info("UID is #{uid}")
          has_enrollments = false
          has_course_sites = false
          has_teaching = false
          has_teaching_sites = false
          has_other_sites = false

          begin
            splash_page = CalCentralPages::SplashPage.new driver
            splash_page.load_page driver
            splash_page.basic_auth(driver, uid)
            status_api = ApiMyStatusPage.new driver
            status_api.get_json driver
            academics_api = ApiMyAcademicsPageSemesters.new driver
            academics_api.get_json driver
            my_classes = CalCentralPages::MyDashboardMyClassesCard.new driver
            my_classes.load_page driver
            term = my_classes.term_name.capitalize

            # ENROLLED CLASSES

            current_student_semester = academics_api.current_semester academics_api.all_semesters
            unless current_student_semester.nil?

              current_semester_name = academics_api.semester_name current_student_semester
              it "shows the current term for student UID #{uid}" do
                expect(term).to eql(current_semester_name)
              end

              if status_api.is_eap?
                my_classes_eap_msg = my_classes.eap_student_msg?
                expect(my_classes_eap_msg).to be true

              else
                has_enrollments = true
                student_classes = academics_api.courses_by_primary_section academics_api.semester_courses(current_student_semester)

                api_student_course_ids = academics_api.semester_card_course_codes(academics_api.all_semesters, current_student_semester)
                api_student_course_titles = academics_api.course_titles student_classes
                api_wait_list_positions = academics_api.wait_list_positions academics_api.wait_list_courses(student_classes)
                api_student_course_site_names = academics_api.semester_course_site_names student_classes
                api_student_course_site_desc = academics_api.semester_course_site_descrips student_classes

                my_classes_course_ids = my_classes.enrolled_course_codes
                my_classes_course_titles = my_classes.enrolled_course_titles
                my_classes_wait_list_positions = my_classes.wait_list_positions
                my_classes_course_site_names = my_classes.enrolled_course_site_names
                my_classes_course_site_desc = my_classes.enrolled_course_site_descrips

                has_course_sites = true if api_student_course_site_names.any?
                testable_users << uid if my_classes_course_ids.any?

                it "shows the enrolled course ids for UID #{uid}" do
                  expect(my_classes_course_ids).to eql(api_student_course_ids)
                end
                it "shows the enrolled course titles for UID #{uid}" do
                  expect(my_classes_course_titles).to eql(api_student_course_titles)
                end
                it "shows the wait list positions for UID #{uid}" do
                  expect(my_classes_wait_list_positions).to eql(api_wait_list_positions)
                end
                it "shows the enrolled course site names for UID #{uid}" do
                  expect(my_classes_course_site_names).to eql(api_student_course_site_names)
                end
                it "shows the enrolled course site descriptions for UID #{uid}" do
                  expect(my_classes_course_site_desc).to eql(api_student_course_site_desc)
                end
              end
            end

            # TEACHING CLASSES

            current_teaching_semester = academics_api.current_semester academics_api.all_teaching_semesters
            unless current_teaching_semester.nil?

              current_semester_name = academics_api.semester_name current_teaching_semester
              it "shows the current term for teaching UID #{uid}" do
                expect(term).to eql(current_semester_name)
              end

              has_teaching = true
              teaching_classes = academics_api.courses_by_primary_section academics_api.semester_courses

              api_teaching_course_ids = academics_api.semester_card_course_codes(academics_api.all_semesters, current_teaching_semester)
              api_teaching_course_titles = academics_api.course_titles teaching_classes
              api_teaching_course_site_names = academics_api.semester_course_site_names teaching_classes
              api_teaching_course_site_desc = academics_api.semester_course_site_descrips teaching_classes

              my_classes_teaching_course_ids = my_classes.teaching_course_codes
              my_classes_teaching_course_titles = my_classes.teaching_course_titles
              my_classes_teaching_site_names = my_classes.teaching_course_site_names
              my_classes_teaching_site_desc = my_classes.teaching_course_site_descrips

              has_teaching_sites = true if api_teaching_course_site_names.any?
              testable_users << uid if my_classes_teaching_course_ids.any?

              it "shows the teaching course ids for UID #{uid}" do
                expect(my_classes_teaching_course_ids).to eql(api_teaching_course_ids)
              end
              it "shows the teaching course titles for UID #{uid}" do
                expect(my_classes_teaching_course_titles).to eql(api_teaching_course_titles)
              end
              it "shows the teaching course site names for UID #{uid}" do
                expect(my_classes_teaching_site_names).to eql(api_teaching_course_site_names)
              end
              it "shows the teaching course site descriptions for UID #{uid}" do
                expect(my_classes_teaching_site_desc).to eql(api_teaching_course_site_desc)
              end

            end

            # OTHER SITES

            other_sites = academics_api.other_sites term
            unless other_sites.nil?

              has_other_sites = true

              api_other_site_names = academics_api.other_site_names other_sites
              api_other_site_desc = academics_api.other_site_descriptions other_sites

              my_classes_other_site_names = my_classes.other_course_site_names
              my_classes_other_site_desc = my_classes.other_course_site_descrips

              it "shows the 'other' course site names for UID #{uid}" do
                expect(my_classes_other_site_names).to eql(api_other_site_names)
              end
              it "shows the 'other' course site descriptions for UID #{uid}" do
                expect(my_classes_other_site_desc).to eql(api_other_site_desc)
              end
            end

            # HEADINGS WITHIN THE CARD

            has_student_heading = my_classes.enrollments_heading_element.visible?
            has_teaching_heading = my_classes.teaching_heading_element.visible?
            has_other_sites_heading = my_classes.other_sites_heading_element.visible?

            if current_student_semester && current_teaching_semester
              it "shows an 'enrollments' heading for UID #{uid}" do
                expect(has_student_heading).to be true
              end
              it "shows a 'teaching' heading for UID #{uid}" do
                expect(has_teaching_heading).to be true
              end
            elsif current_student_semester && academics_api.other_sites(term).any? && current_teaching_semester.nil?
              it "shows an 'enrollments' heading for UID #{uid}" do
                expect(has_student_heading).to be true
              end
              it "shows no 'teaching' heading for UID #{uid}" do
                expect(has_teaching_heading).to be false
              end
            elsif current_teaching_semester && academics_api.other_sites(term).any? && current_student_semester.nil?
              it "shows a 'teaching' heading for UID #{uid}" do
                expect(has_teaching_heading).to be true
              end
              it "shows no 'enrollments' heading for UID #{uid}" do
                expect(has_student_heading).to be false
              end
            end


            if current_student_semester
              if current_teaching_semester
                it "shows an Enrollments heading for UID #{uid}" do
                  expect(has_student_heading).to be true
                end
                it "shows a Teaching heading for UID #{uid}" do
                  expect(has_teaching_heading).to be true
                end
              elsif academics_api.other_sites(term).any?
                it "shows an Enrollments heading for UID #{uid}" do
                  expect(has_student_heading).to be true
                end
                it "shows no Teaching heading for UID #{uid}" do
                  expect(has_teaching_heading).to be false
                end
              else
                it "shows no Enrollments heading for UID #{uid}" do
                  expect(has_student_heading).to be true
                end
                it "shows no Teaching heading for UID #{uid}" do
                  expect(has_teaching_heading).to be false
                end
              end
            else
              if current_teaching_semester
                if academics_api.other_sites(term).any?
                  it "shows no Enrollments heading for UID #{uid}" do
                    expect(has_student_heading).to be true
                  end
                  it "shows a Teaching heading for UID #{uid}" do
                    expect(has_teaching_heading).to be true
                  end
                else
                  it "shows no Enrollments heading for UID #{uid}" do
                    expect(has_student_heading).to be true
                  end
                  it "shows no Teaching heading for UID #{uid}" do
                    expect(has_teaching_heading).to be false
                  end
                end
              else
                it "shows no Enrollments heading for UID #{uid}" do
                  expect(has_student_heading).to be true
                end
                it "shows no Teaching heading for UID #{uid}" do
                  expect(has_teaching_heading).to be false
                end
              end
            end

            unless academics_api.other_sites(term).empty?
              it "shows an Other Site Memberships heading for UID #{uid}" do
                expect(has_other_sites_heading).to be true
              end
            end

            # MESSAGING FOR USERS WITH NO CLASSES OR SITES

            if current_student_semester.nil? && current_teaching_semester.nil? && academics_api.other_sites(term).empty?

              has_not_enrolled_msg = my_classes.not_enrolled_msg?

              it "shows a 'you are not enrolled' message to UID #{uid}" do
                expect(has_not_enrolled_msg).to be true
              end

              has_registrar_link = WebDriverUtils.verify_external_link(driver, my_classes.registrar_link_element, 'Welcome to our web site - Office Of The Registrar')
              has_cal_student_central_link = WebDriverUtils.verify_external_link(driver, my_classes.cal_student_central_link_element, 'Welcome! | Cal Student Central')

              if status_api.is_student? || status_api.is_faculty?
                it "offers an Office of the Registrar link to UID #{uid}" do
                  expect(has_registrar_link).to be true
                end
                it "offers a Cal Student Central link to UID #{uid}" do
                  expect(has_cal_student_central_link).to be true
                end
              else
                it "offers no Office of the Registrar link to UID #{uid}" do
                  expect(has_registrar_link).to be false
                end
                it "offers no Cal Student Central link to UID #{uid}" do
                  expect(has_cal_student_central_link).to be false
                end
              end
            end

          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")
          ensure
            CSV.open(test_output, 'a+') do |user_info_csv|
              user_info_csv << [uid, has_enrollments, has_course_sites, has_teaching, has_teaching_sites, has_other_sites]
            end
          end
        end
      end
      it 'has student or teaching classes for at least one of the test users' do
        expect(testable_users.any?).to be true
      end
    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n ")
    ensure
      WebDriverUtils.quit_browser(driver)
    end
  end
end
