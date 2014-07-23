require 'spec_helper'

describe 'Calendar Integration Full Stack', testext: true do
  before do
    Calendar::Queries.stub(:get_all_courses).and_return(
      [{
         'term_yr' => 2013,
         'term_cd' => 'D',
         'course_cntl_num' => 12345,
         'course_name' => 'Testing 1A',
         'multi_entry_cd' => '',
         'building_name' => 'Dwinelle',
         'room_number' => '117',
         'meeting_days' => ' M W',
         'meeting_start_time' => '0200',
         'meeting_start_time_ampm_flag' => 'P',
         'meeting_end_time' => '0300',
         'meeting_end_time_ampm_flag' => 'P'
       }])
    Calendar::Queries.stub(:get_whitelisted_students_in_course).and_return(
      [{
         'ldap_uid' => '904715',
         'official_bmail_address' => 'ctweney@testg.berkeley.edu.test-google-a.com'
       }])
    Calendar::User.create({uid: '904715'})
  end

  let!(:get_proxy) {
    GoogleApps::EventsGet.new(
      access_token: Settings.class_calendar.access_token,
      refresh_token: Settings.class_calendar.refresh_token,
      expiration_time: DateTime.now.to_i + 3599)
  }

  context 'with a real working Google connection' do

    it 'should create and then delete events' do

      # EVENT CREATES ------------------------------------------------------------------------------------
      # set up the queue
      queued = Calendar::Preprocessor.new.get_entries
      expect(queued.length).to eq 1
      expect(queued[0].ccn).to eq 12345
      expect(queued[0].transaction_type).to eq Calendar::QueuedEntry::CREATE_TRANSACTION
      queued.each do |entry|
        entry.save
      end

      entries = Calendar::QueuedEntry.all
      expect(entries.length).to eq 1

      # export the queue (1 attendee; event CREATE)
      exported = Calendar::Exporter.new.ship_entries entries
      expect(exported).to be_true

      first_job = Calendar::Job.limit(1).order(id: :desc).first
      expect(first_job.error_count).to eq 0
      expect(first_job.total_entry_count).to eq 1

      saved_entry = Calendar::LoggedEntry.where({job_id: first_job.id}).first
      expect(saved_entry).to be
      event_id = saved_entry.event_id
      event_on_google = get_proxy.get_event event_id
      expect(event_on_google).to be
      json = JSON.parse(event_on_google.body)
      expect(json['location']).to eq 'Dwinelle 117, UC Berkeley'

      # EVENT UPDATES ------------------------------------------------------------------------------------
      # now change the class location
      Calendar::Queries.stub(:get_all_courses).and_return(
        [{
           'term_yr' => 2013,
           'term_cd' => 'D',
           'course_cntl_num' => 12345,
           'course_name' => 'Testing 1A',
           'multi_entry_cd' => '',
           'building_name' => 'VLSB',
           'room_number' => '100',
           'meeting_days' => ' M W',
           'meeting_start_time' => '0200',
           'meeting_start_time_ampm_flag' => 'P',
           'meeting_end_time' => '0300',
           'meeting_end_time_ampm_flag' => 'P'
         }])

      # now preprocess again. This will create an UPDATE transction for the existing event.
      queued = Calendar::Preprocessor.new.get_entries
      expect(queued.length).to eq 1
      expect(queued[0].ccn).to eq 12345
      expect(queued[0].transaction_type).to eq Calendar::QueuedEntry::UPDATE_TRANSACTION
      queued.each do |entry|
        entry.save
      end

      entries = Calendar::QueuedEntry.all
      expect(entries.length).to eq 1

      # now export again
      exported = Calendar::Exporter.new.ship_entries entries
      expect(exported).to be_true

      second_job = Calendar::Job.limit(1).order(id: :desc).first
      expect(second_job.error_count).to eq 0
      expect(second_job.total_entry_count).to eq 1

      # now make sure the event on google has the updated location
      saved_entry = Calendar::LoggedEntry.where({job_id: second_job.id}).first
      expect(saved_entry).to be
      event_id = saved_entry.event_id
      event_on_google = get_proxy.get_event event_id
      expect(event_on_google).to be
      json = JSON.parse(event_on_google.body)
      expect(json['location']).to eq 'VLSB 100, UC Berkeley'

      # EVENT DELETES ------------------------------------------------------------------------------------
      # now take the user off the whitelist
      user = Calendar::User.where({uid: '904715'})[0]
      user.delete
      Calendar::Queries.stub(:get_whitelisted_students_in_course).and_return([])

      # now preprocess again. This should produce a DELETE transaction for the existing event.
      queued = Calendar::Preprocessor.new.get_entries
      expect(queued.length).to eq 1
      expect(queued[0].ccn).to eq 12345
      expect(queued[0].transaction_type).to eq Calendar::QueuedEntry::DELETE_TRANSACTION
      queued.each do |entry|
        entry.save
      end

      entries = Calendar::QueuedEntry.all
      expect(entries.length).to eq 1

      # now export again
      exported = Calendar::Exporter.new.ship_entries entries
      expect(exported).to be_true

      third_job = Calendar::Job.limit(1).order(id: :desc).first
      expect(third_job.error_count).to eq 0
      expect(third_job.total_entry_count).to eq 1

      # after EVENT DELETES -----------------------------------------------------------------------------
      # now preprocess again. This should produce an empty list (since the event has already been deleted,
      # and nobody is on the whitelist now).
      queued = Calendar::Preprocessor.new.get_entries
      expect(queued.length).to eq 0

    end

  end
end
