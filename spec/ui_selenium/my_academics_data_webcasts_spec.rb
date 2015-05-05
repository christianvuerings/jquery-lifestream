require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'csv'
require 'json'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/my_academics_class_page'

describe 'My Academics webcasts card', :testui => true do

  if ENV["UI_TEST"]

    include ClassLogger

    begin

      driver = WebDriverUtils.launch_browser

      test_users = UserUtils.load_test_users
      testable_users = []
      test_users.each do |user|
        unless user['webcast'].nil?
          uid = user['uid'].to_s
          logger.info("UID is #{uid}")
          course = user['webcast']['course']
          class_page = user['webcast']['classPagePath']
          lecture_count = user['webcast']['lectures']
          video_you_tube_id = user['webcast']['video']
          video_itunes = user['webcast']['itunesVideo']
          audio_url = user['webcast']['audio']
          audio_download = user['webcast']['audioDownload']
          audio_itunes = user['webcast']['itunesAudio']

          begin
            splash_page = CalCentralPages::SplashPage.new(driver)
            splash_page.load_page(driver)
            splash_page.basic_auth(driver, uid)
            my_academics = CalCentralPages::MyAcademicsClassPage.new(driver)
            my_academics.load_class_page(driver, class_page)
            my_academics.wait_for_webcasts
            testable_users.push(uid)

            if video_you_tube_id.nil? && !audio_url.nil?
              my_academics.audio_source_element.when_present(timeout=WebDriverUtils.academics_timeout)
              has_right_default_tab = my_academics.audio_element.visible?
              it "shows the audio tab by default for UID #{uid}" do
                expect(has_right_default_tab).to be true
              end
              has_video_tab = my_academics.video_tab?
              it "shows no video tab for UID #{uid}" do
                expect(has_video_tab).to be false
              end
            elsif video_you_tube_id.nil? && audio_url.nil?
              has_no_webcast_message = my_academics.no_webcast_msg?
              it "shows a 'no webcasts' message for UID #{uid}" do
                expect(has_no_webcast_message).to be true
              end
            elsif audio_url.nil? && !video_you_tube_id.nil?
              my_academics.video_thumbnail_element.when_present(timeout=WebDriverUtils.academics_timeout)
              has_right_default_tab = my_academics.video_thumbnail_element.visible?
              it "shows the video tab by default for UID #{uid}" do
                expect(has_right_default_tab).to be true
              end
              has_audio_tab = my_academics.audio_tab?
              it "shows no audio tab for UID #{uid}" do
                expect(has_audio_tab).to be false
              end
            else
              my_academics.video_thumbnail_element.when_present(timeout=WebDriverUtils.academics_timeout)
              has_right_default_tab = my_academics.video_thumbnail_element.visible?
              it "shows the video tab by default for UID #{uid}" do
                expect(has_right_default_tab).to be true
              end
            end

            unless video_you_tube_id.nil?
              my_academics.video_thumbnail_element.when_present(timeout=WebDriverUtils.page_event_timeout)
              all_visible_video_lectures = my_academics.video_select_element.options.length
              thumbnail_present = my_academics.video_thumbnail_element.attribute('src').include? video_you_tube_id
              auto_play = my_academics.you_tube_video_auto_plays?(driver)
              it "shows all the available lecture videos for UID #{uid}" do
                expect(all_visible_video_lectures).to eql(lecture_count)
              end
              it "shows the right video thumbnail for UID #{uid}" do
                expect(thumbnail_present).to be true
              end
              it "plays the video automatically when clicked for UID #{uid}" do
                expect(auto_play).to be true
              end
              unless video_itunes.nil?
                itunes_video_link_present = WebDriverUtils.verify_external_link(driver, my_academics.itunes_video_link_element, "#{course} - Download free content from UC Berkeley on iTunes")
                it "shows an iTunes video URL for UID #{uid}" do
                  expect(itunes_video_link_present).to be true
                end
              end
            end

            unless audio_url.nil?
              unless video_you_tube_id.nil?
                my_academics.audio_tab_element.when_present(timeout=WebDriverUtils.page_event_timeout)
                my_academics.audio_tab
              end
              my_academics.audio_source_element.when_present(timeout=WebDriverUtils.page_event_timeout)
              all_visible_audio_lectures = my_academics.audio_select_element.options.length
              audio_player_present = my_academics.audio_source_element.attribute('src').include? audio_url
              it "shows all the available lecture audio recordings for UID #{uid}" do
                expect(all_visible_audio_lectures).to eql(lecture_count)
              end
              it "shows the right audio player content for UID #{uid}" do
                expect(audio_player_present).to be true
              end
              unless audio_download.nil?
                audio_download_link_present = my_academics.audio_download_link_element.attribute('href').eql? audio_download
                it "shows an audio download link for UID #{uid}" do
                  expect(audio_download_link_present).to be true
                end
              end
              unless audio_itunes.nil?
                itunes_audio_link_present = WebDriverUtils.verify_external_link(driver, my_academics.itunes_audio_link_element, "#{course} - Download free content from UC Berkeley on iTunes")
                it "shows an iTunes audio URL for UID #{uid}" do
                  expect(itunes_audio_link_present).to be true
                end
              end
            end

          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n ")
          end
        end
      end
      it 'has a webcast UI for at least one of the test users' do
        expect(testable_users.length).to be > 0
      end
    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n ")
    ensure
      WebDriverUtils.quit_browser(driver)
    end
  end
end
