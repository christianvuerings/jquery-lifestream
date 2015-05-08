require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'csv'
require 'json'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/my_academics_page'
require_relative 'pages/my_academics_classes_card'
require_relative 'pages/my_academics_teaching_card'
require_relative 'pages/my_academics_class_page'
require_relative 'pages/api_my_status_page'
require_relative 'pages/api_my_classes_page'
require_relative 'pages/api_my_academics_page_semesters'

describe 'My Academics teaching', :testui => true do

  if ENV["UI_TEST"]

    include ClassLogger

    begin

      driver = WebDriverUtils.launch_browser

      test_users = UserUtils.load_test_users
      test_output = UserUtils.initialize_output_csv(self)
      testable_users = []

      CSV.open(test_output, 'wb') do |user_info_csv|
        user_info_csv << ['UID', 'GSI', 'Semester', 'Course Title', 'Listing']
      end

      test_users.each do |user|
        if user['teaching']
          uid = user['uid'].to_s
          logger.info("UID is #{uid}")

          begin
            splash_page = CalCentralPages::SplashPage.new(driver)
            splash_page.load_page(driver)
            splash_page.basic_auth(driver, uid)
            status_api_page = ApiMyStatusPage.new(driver)
            status_api_page.get_json(driver)

            if status_api_page.is_faculty? && status_api_page.has_academics_tab?
              academics_api_page = ApiMyAcademicsPageSemesters.new(driver)
              academics_api_page.get_json(driver)
              all_semesters = academics_api_page.all_teaching_semesters
              teaching_card = CalCentralPages::MyAcademicsTeachingCard.new(driver)
              teaching_card.load_page(driver)
              teaching_card.page_heading_element.when_visible(timeout=WebDriverUtils.academics_timeout)

              if all_semesters.present?
                testable_users.push(uid)

                all_semester_names = academics_api_page.semester_names(all_semesters)
                default_semesters = academics_api_page.default_semesters_in_ui(all_semesters)
                default_semester_names = academics_api_page.semester_names(default_semesters)
                current_semester = academics_api_page.current_semester(all_semesters)

                # MY ACADEMICS CLASSES CARD

                unless current_semester.nil? || status_api_page.is_student?
                  current_semester_name = academics_api_page.semester_name(current_semester)
                  classes_card = CalCentralPages::MyAcademicsClassesCard.new(driver)

                  api_current_courses = academics_api_page.semester_courses(current_semester)
                  api_current_listing_codes = academics_api_page.semester_listing_course_codes(current_semester)
                  api_current_course_titles = academics_api_page.course_titles(api_current_courses)

                  my_academics_semester_name = classes_card.semester_heading
                  my_academics_course_codes = classes_card.all_teaching_course_codes
                  my_academics_course_titles = classes_card.all_teaching_course_titles

                  it "shows the current semester class card on the landing page for UID #{uid}" do
                    expect(my_academics_semester_name).to eql(current_semester_name)
                  end
                  it "shows the current semester course codes on the landing page class card for UID #{uid}" do
                    expect(my_academics_course_codes).to eql(api_current_listing_codes)
                  end
                  it "shows the current semester course titles on the landing page class card for UID #{uid}" do
                    expect(my_academics_course_titles).to eql(api_current_course_titles)
                  end
                end

                # MY ACADEMICS TEACHING CARD

                shows_default_semesters = teaching_card.teaching_terms_visible?(default_semester_names)
                it "shows future, current, and most recent past teaching semesters by default for UID #{uid}" do
                  expect(shows_default_semesters).to be true
                end
                show_more_button_visible = teaching_card.show_more_element.visible?
                if all_semesters.length > default_semesters.length
                  it "offers a 'Show More' button for UID #{uid}" do
                    expect(show_more_button_visible).to be true
                  end
                  teaching_card.show_more
                  shows_more_semesters = teaching_card.teaching_terms_visible?(all_semester_names)
                  it "can show all semesters for UID #{uid}" do
                    expect(shows_more_semesters).to be true
                  end
                else
                  it "offers no 'Show More' button for UID #{uid}" do
                    expect(show_more_button_visible).to be false
                  end
                end

                all_semesters.each do |semester|
                  if teaching_card.show_more_element.visible?
                    teaching_card.show_more
                  end
                  begin
                    semester_name = academics_api_page.semester_name(semester)
                    semester_courses = academics_api_page.semester_courses(semester)

                    teaching_card_course_codes = teaching_card.all_semester_course_codes(driver, semester_name)
                    teaching_card_course_titles = teaching_card.all_semester_course_titles(driver, semester_name)

                    api_course_codes = academics_api_page.semester_listing_course_codes(semester)
                    api_course_titles = academics_api_page.course_titles(semester_courses)

                    it "shows the course codes for #{semester_name} on the teaching card for UID #{uid}" do
                      expect(teaching_card_course_codes).to eql(api_course_codes)
                    end
                    it "shows the course titles for #{semester_name} on the teaching card for UID #{uid}" do
                      expect(teaching_card_course_titles).to eql(api_course_titles)
                    end

                    # SEMESTER PAGES

                    teaching_card.click_teaching_semester_link(driver, semester_name)
                    semester_page = CalCentralPages::MyAcademicsClassesCard.new(driver)

                    api_semester_courses = academics_api_page.semester_courses(semester)
                    api_semester_listing_codes = academics_api_page.semester_listing_course_codes(semester)
                    api_semester_course_titles = academics_api_page.course_titles(api_semester_courses)

                    semester_page_course_codes = semester_page.all_teaching_course_codes
                    semester_page__course_titles = semester_page.all_teaching_course_titles

                    it "shows the course codes on the #{semester_name} semester page for UID #{uid}" do
                      expect(semester_page_course_codes).to eql(api_semester_listing_codes)
                    end
                    it "shows the course titles on the #{semester_name} semester page for UID #{uid}" do
                      expect(semester_page__course_titles).to eql(api_semester_course_titles)
                    end

                    # CLASS PAGES

                    api_semester_courses.each do |course|

                      listing_codes = academics_api_page.course_listing_course_codes(course)
                      listing_codes.each do |course_code|

                        semester_page.click_class_link_by_text(driver, course_code)
                        class_page = CalCentralPages::MyAcademicsClassPage.new(driver)
                        class_page.class_info_heading_element.when_visible(WebDriverUtils.page_load_timeout)

                        api_course_title = academics_api_page.course_title(course)
                        api_sections = academics_api_page.sections_by_listing(course)
                        api_section_schedule_labels = academics_api_page.section_schedule_labels(api_sections)
                        api_section_schedules = academics_api_page.course_section_schedules(api_sections)
                        api_section_instructor_labels = academics_api_page.section_labels(api_sections)
                        api_section_instructors = academics_api_page.course_instructor_names(api_sections)

                        class_page_course_title = class_page.course_title
                        class_page_cross_listings = class_page.all_cross_listings
                        class_page_section_labels = class_page.all_section_schedule_labels
                        class_page_section_schedules = class_page.all_teaching_section_schedules
                        class_page_section_instructors = class_page.all_section_instructors(driver, api_section_instructor_labels)

                        it "shows the course title on the #{semester_name} #{course_code} class page for UID #{uid}" do
                          expect(class_page_course_title).to eql(api_course_title)
                        end
                        if listing_codes.length > 1
                          it "shows the cross listings on the #{semester_name} #{course_code} class page for UID #{uid}" do
                            expect(class_page_cross_listings).to eql(listing_codes)
                          end
                        else
                          it "shows no cross listings on the #{semester_name} #{course_code} class page for UID #{uid}" do
                            expect(class_page_cross_listings).to be_empty
                          end
                          has_cross_listing_heading = class_page.cross_listing_heading?
                          it "shows no cross listings heading on the #{semester_name} #{course_code} class page for UID #{uid}" do
                            expect(has_cross_listing_heading).to be false
                          end
                        end
                        it "shows the section labels on the #{semester_name} #{course_code} class page for UID #{uid}" do
                          expect(class_page_section_labels).to eql(api_section_schedule_labels)
                        end
                        it "shows the section schedules on the #{semester_name} #{course_code} class page for UID #{uid}" do
                          expect(class_page_section_schedules).to eql(api_section_schedules)
                        end
                        it "shows the section instructors on the #{semester_name} #{course_code} class page for UID #{uid}" do
                          expect(class_page_section_instructors).to eql(api_section_instructors)
                        end

                        if semester == academics_api_page.current_semester(all_semesters) || academics_api_page.future_semesters(all_semesters).include?(semester)
                          CSV.open(test_output, 'a+') do |user_info_csv|
                            user_info_csv << [uid, status_api_page.is_student?, semester_name, api_course_title, course_code]
                          end
                        end

                        class_page.back

                      end
                    end

                    semester_page.back

                  end
                end
              else
                has_no_classes_msg = teaching_card.no_classes_msg?

                it "shows a 'you have no courses assigned to you' message for UID #{uid}" do
                  expect(has_no_classes_msg).to be true
                end

              end
            end
          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n ")
          end
        end
      end

      it 'has teaching information for at least one of the test UIDs' do
        expect(testable_users.length).to be > 0
      end

    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n ")
    ensure
      WebDriverUtils.quit_browser(driver)
    end
  end
end
