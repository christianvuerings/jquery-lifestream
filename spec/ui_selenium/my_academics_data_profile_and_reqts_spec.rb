require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/my_academics_profile_card'
require_relative 'pages/my_academics_university_reqts_card'
require_relative 'pages/splash_page'
require_relative 'pages/api_my_status_page'
require_relative 'pages/api_my_academics_page_semesters'

describe 'My Academics profile and university requirements cards', :testui => true do

  if ENV["UI_TEST"]

    include ClassLogger

    begin
      driver = WebDriverUtils.launch_browser
      test_output = UserUtils.initialize_output_csv(self)
      test_users = UserUtils.load_test_users
      testable_users = []

      CSV.open(test_output, 'wb') do |user_info_csv|
        user_info_csv << ['UID', 'User Type', 'Term Transition', 'Standing', 'Schools', 'Majors', 'Level', 'Units']
      end

      test_users.each do |user|
        if user['profile']
          uid = user['uid'].to_s
          logger.info("UID is #{uid}")
          user_type = nil
          term_transition = false
          api_standing = nil
          api_colleges = nil
          api_majors = nil
          api_level = nil
          api_units = nil

          begin
            splash_page = CalCentralPages::SplashPage.new(driver)
            splash_page.load_page(driver)
            splash_page.basic_auth(driver, uid)
            status_api_page = ApiMyStatusPage.new(driver)
            status_api_page.get_json(driver)
            academics_api_page= ApiMyAcademicsPageSemesters.new(driver)
            academics_api_page.get_json(driver)
            profile_card = CalCentralPages::MyAcademicsProfileCard.new(driver)
            reqts_card = CalCentralPages::MyAcademicsUniversityReqtsCard.new(driver)
            profile_card.load_page(driver)

            if status_api_page.has_academics_tab? && status_api_page.has_student_history?
                profile_card.profile_card_element.when_visible(timeout=WebDriverUtils.academics_timeout)

                # NAME AND IDS
                api_full_name = status_api_page.full_name
                api_sid = status_api_page.sid
                my_academics_full_name = profile_card.name
                my_academics_uid = profile_card.uid
                my_academics_sid = profile_card.sid
                it "show the full name of UID #{uid}" do
                  expect(my_academics_full_name).to eql(api_full_name)
                end
                it "show the UID for UID #{uid}" do
                  expect(my_academics_uid).to eql(uid)
                end
                it "show the SID for UID #{uid}" do
                  expect(my_academics_sid).to eql(api_sid)
                end

                # GPA
                if academics_api_page.gpa == '0.0' || status_api_page.is_concurrent_enroll_student?
                  has_gpa = profile_card.gpa?
                  it "show no GPA for UID #{uid}" do
                    expect(has_gpa).to be false
                  end
                else
                  api_gpa = academics_api_page.gpa
                  my_academics_gpa = profile_card.gpa
                  it "show the GPA for UID #{uid}" do
                    expect(my_academics_gpa).to eql(api_gpa)
                  end
                end

                # UNITS
                if academics_api_page.ttl_units.nil?
                  has_units = profile_card.units?
                  it "show no units for UID #{uid}" do
                    expect(has_units).to be false
                  end
                else
                  api_units = academics_api_page.ttl_units.to_s
                  my_academics_units = profile_card.units
                  it "show the units for UID #{uid}" do
                    expect(my_academics_units).to eql(api_units)
                  end
                end

                # STANDING
                unless academics_api_page.has_no_standing?
                  api_colleges = academics_api_page.colleges
                  api_majors = academics_api_page.majors
                  api_standing = academics_api_page.standing
                  api_level = academics_api_page.level
                  my_academics_colleges = profile_card.all_colleges
                  my_academics_majors = profile_card.all_majors
                  my_academics_standing = profile_card.standing
                  my_academics_level = profile_card.level
                  it "show the colleges for UID #{uid}" do
                    expect(my_academics_colleges).to eql(api_colleges)
                  end
                  it "show the majors for UID #{uid}" do
                    expect(my_academics_majors).to eql(api_majors)
                  end
                  it "show the standing for UID #{uid}" do
                    expect(my_academics_standing).to eql(api_standing)
                  end

                  # LEVEL - AP and NON-AP
                  my_academics_level_label = profile_card.level_label
                  it "show the level for UID #{uid}" do
                    expect(my_academics_level).to eql(api_level)
                  end
                  if academics_api_page.standing == 'Undergraduate'
                    it "show the 'Including AP' level label for undergrad UID #{uid}" do
                      expect(my_academics_level_label).to eql('Including AP')
                    end
                    api_level_no_ap = academics_api_page.non_ap_level
                    my_academics_level_no_ap = profile_card.level_non_ap
                    it "show the level without AP credit for undergrad UID #{uid}" do
                      expect(my_academics_level_no_ap).to eql(api_level_no_ap)
                    end
                  else
                    it "show the 'Current' level label for grad UID #{uid}" do
                      expect(my_academics_level_label).to eql('Current')
                    end
                    has_level_no_ap = profile_card.level_non_ap?
                    it "show no level without AP credit for grad UID #{uid}" do
                      expect(has_level_no_ap).to be false
                    end
                  end
                end

                # UNDERGRAD REQUIREMENTS
                if academics_api_page.standing == 'Undergraduate'

                  if academics_api_page.writing_reqt_met?
                    my_academics_writing_met = reqts_card.writing_reqt_met?
                    it "show 'UC Entry Level Writing' 'Completed' for UID #{uid}" do
                      expect(my_academics_writing_met).to be true
                    end
                  else
                    my_academics_writing_unmet = reqts_card.writing_reqt_unmet?
                    writing_unmet_link_works = WebDriverUtils.verify_external_link(driver, reqts_card.writing_reqt_unmet_element, 'Undergraduate Degree Requirements - Office Of The Registrar')
                    it "show 'UC Entry Level Writing' 'Incomplete' for UID #{uid}" do
                      expect(my_academics_writing_unmet).to be true
                    end
                    it "offers a link to degree requirements for UID #{uid}" do
                      expect(writing_unmet_link_works).to be true
                    end
                  end

                  if academics_api_page.history_reqt_met?
                    my_academics_history_met = reqts_card.history_reqt_met?
                    it "show 'American History' 'Completed' for UID #{uid}" do
                      expect(my_academics_history_met).to be true
                    end
                  else
                    my_academics_history_unmet = reqts_card.history_reqt_unmet?
                    history_unmet_link_works = WebDriverUtils.verify_external_link(driver, reqts_card.history_reqt_unmet_element, 'Undergraduate Degree Requirements - Office Of The Registrar')
                    it "show 'American History' 'Incomplete' for UID #{uid}" do
                      expect(my_academics_history_unmet).to be true
                    end
                    it "offer a link to degree requirements for UID #{uid}" do
                      expect(history_unmet_link_works).to be true
                    end
                  end

                  if academics_api_page.institutions_reqt_met?
                    my_academics_institutions_met = reqts_card.institutions_reqt_met?
                    it "show 'American Institutions' 'Completed' for UID #{uid}" do
                      expect(my_academics_institutions_met).to be true
                    end
                  else
                    my_academics_institutions_unmet = reqts_card.institutions_reqt_unmet?
                    institutions_unmet_link_works = WebDriverUtils.verify_external_link(driver, reqts_card.institutions_reqt_unmet_element, 'Undergraduate Degree Requirements - Office Of The Registrar')
                    it "show 'American Institutions' 'Incomplete' for UID #{uid}" do
                      expect(my_academics_institutions_unmet).to be true
                    end
                    it "offer a link to degree requirements for UID #{uid}" do
                      expect(institutions_unmet_link_works).to be true
                    end
                  end

                  if academics_api_page.cultures_reqt_met?
                    my_academics_cultures_met = reqts_card.cultures_reqt_met?
                    it "show 'American Cultures' 'Completed' for UID #{uid}" do
                      expect(my_academics_cultures_met).to be true
                    end
                  else
                    my_academics_cultures_unmet = reqts_card.cultures_reqt_unmet?
                    cultures_unmet_link_works = WebDriverUtils.verify_external_link(driver, reqts_card.cultures_reqt_unmet_element, 'Undergraduate Degree Requirements - Office Of The Registrar')
                    it "show 'American Cultures' 'Incomplete' for UID #{uid}" do
                      expect(my_academics_cultures_unmet).to be true
                    end
                    it "offer a link to degree requirements for UID #{uid}" do
                      expect(cultures_unmet_link_works).to be true
                    end
                  end

                else
                  has_reqts_card = reqts_card.reqts_table?
                  it "show no 'University Requirements' UI for UID #{uid}" do
                    expect(has_reqts_card).to be false
                  end
                end

              # STUDENT STATUS MESSAGING VARIATIONS
              if academics_api_page.has_no_standing?

                if status_api_page.is_student?
                  if academics_api_page.units_attempted == 0
                    user_type = 'new student'
                    has_new_student_msg = profile_card.new_student_msg?
                    it "show a new student message to UID #{uid}" do
                      expect(has_new_student_msg).to be true
                    end
                  else
                    user_type = 'unregistered student'
                    has_non_reg_msg = profile_card.non_reg_student_msg?
                    it "show a 'not registered' message to UID #{uid}" do
                      expect(has_non_reg_msg).to be true
                    end
                  end

                elsif status_api_page.is_ex_student? && academics_api_page.all_teaching_semesters.nil?
                  user_type = 'ex-student'
                  has_ex_student_msg = profile_card.ex_student_msg?
                  it "show an ex-student message to UID #{uid}" do
                    expect(has_ex_student_msg).to be true
                  end

                elsif status_api_page.is_concurrent_enroll_student?
                  user_type = 'concurrent enrollment'
                  has_concur_student_msg = profile_card.concur_student_msg?
                  has_uc_ext_link = WebDriverUtils.verify_external_link(driver, profile_card.uc_ext_link_element, 'Concurrent Enrollment | Student Services | UC Berkeley Extension')
                  has_eap_link = WebDriverUtils.verify_external_link(driver, profile_card.eap_link_element, 'Exchange Students | Berkeley International Office')
                  it "show a concurrent enrollment student message to UID #{uid}" do
                    expect(has_concur_student_msg).to be true
                  end
                  it "show a concurrent enrollment UC Extension link to UID #{uid}" do
                    expect(has_uc_ext_link).to be true
                  end
                  it "show a concurrent enrollment EAP link to UID #{uid}" do
                    expect(has_eap_link).to be true
                  end
                end

              else
                user_type = 'existing student'
                testable_users.push(uid)
                if academics_api_page.term_transition?
                  term_transition = true
                  api_term_transition = "Academic status as of #{academics_api_page.term_name}"
                  my_academics_term_transition = profile_card.term_transition_heading
                  it "show the term transition heading to UID #{uid}" do
                    expect(my_academics_term_transition).to eql(api_term_transition)
                  end
                end
              end

            elsif academics_api_page.all_teaching_semesters.nil?
              user_type = 'no data'
              no_data_msg = profile_card.no_data_heading?
              it "show a 'Data not available' message to UID #{uid}" do
                expect(no_data_msg).to be true
              end
            end

          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")
          ensure
            CSV.open(test_output, 'a+') do |user_info_csv|
              user_info_csv << [uid, user_type, term_transition, api_standing, api_colleges, api_majors, api_level, api_units]
            end
          end
        end
      end

      it 'have academic profile data for at least one of the test UIDs' do
        expect(testable_users.any?).to be true
      end

    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n ")
    ensure
      logger.info('Quitting the browser')
      WebDriverUtils.quit_browser(driver)
    end
  end
end
