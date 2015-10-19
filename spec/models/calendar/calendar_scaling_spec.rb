# Full-stack test used to test performance of the calendar integration. This is not
# meant to be run in the normal course of testing!
describe 'Calendar Integration Scaling Test', ignore: true do
  before do
    courses = []
    (1..100).each do |i|
      courses << {
        'term_yr' => 2013,
        'term_cd' => 'D',
        'course_cntl_num' => i,
        'course_name' => "Test #{i}",
        'multi_entry_cd' => '',
        'building_name' => 'Dwinelle',
        'room_number' => '117',
        'meeting_days' => ' M W',
        'meeting_start_time' => '0200',
        'meeting_start_time_ampm_flag' => 'P',
        'meeting_end_time' => '0300',
        'meeting_end_time_ampm_flag' => 'P'
      }
    end

    Calendar::Queries.stub(:get_all_courses).and_return(courses)
    Calendar::Queries.stub(:get_whitelisted_students_in_course).and_return(
      [{
         'ldap_uid' => '904715',
         'official_bmail_address' => 'michelincat74@gmail.com'
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

    it 'should create events' do

      # EVENT CREATES ------------------------------------------------------------------------------------
      # set up the queue
      queued = Calendar::Preprocessor.new.get_entries
      queued.each do |entry|
        entry.save
      end

      entries = Calendar::QueuedEntry.all

      start = Time.now.to_i

      # export the queue
      exported = Calendar::Exporter.new.ship_entries entries

      duration = Time.now.to_i - start
      Rails.logger.warn "Exported #{entries.length} entries in #{duration}s"
      expect(exported).to be_truthy

      # EVENT DELETES ------------------------------------------------------------------------------------
      # now take the user off the whitelist
      user = Calendar::User.where({uid: '904715'})[0]
      user.delete
      Calendar::Queries.stub(:get_whitelisted_students_in_course).and_return([])

      # now preprocess again. This should produce a DELETE transaction for the existing event.
      queued = Calendar::Preprocessor.new.get_entries
      queued.each do |entry|
        entry.save
      end

      entries = Calendar::QueuedEntry.all

      # now export again
      start = Time.now.to_i
      exported = Calendar::Exporter.new.ship_entries entries
      duration = Time.now.to_i - start
      Rails.logger.warn "Deleted #{entries.length} entries in #{duration}s"

      expect(exported).to be_truthy

    end

  end
end
