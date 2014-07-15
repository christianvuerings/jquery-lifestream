require 'spec_helper'

describe Calendar::Preprocessor do

  shared_examples 'it has a non-empty array of ClassCalendarQueue entries' do
    it 'each entry has the expected mandatory event data fields' do
      expect(subject).to be_present
      subject.each do |entry|
        expect(entry).to be_instance_of(Calendar::QueuedEntry)
        json = JSON.parse(entry.event_data)
        expect(json['location']).to be
        expect(json['summary']).to be
        expect(json['start']['dateTime']).to be
        expect(json['end']['dateTime']).to be
        expect(json['attendees']).to be
        expect(json['guestsCanSeeOtherGuests']).to be_false
        expect(json['guestsCanInviteOthers']).to be_false
        expect(json['locked']).to be_true
        expect(json['recurrence'].length).to eq 1
      end
    end
  end

  describe '#get_entries' do
    subject { Calendar::Preprocessor.new.get_entries }
    context 'when the user whitelist is empty' do
      it 'returns an empty list' do
        expect(subject).to be_empty
      end
    end
    context 'when the user whitelist has a non-enrolled student on it' do
      before do
        Calendar::User.create({uid: '1'})
      end
      it 'returns an empty array' do
        expect(subject).to be_empty
      end
    end
    context 'when the whitelist has an enrolled student on it', if: Calendar::Queries.test_data? do
      before do
        Calendar::User.create({uid: '300939'})

        Calendar::LoggedEntry.create(
          {
            year: 2013,
            term_cd: 'D',
            ccn: 7309,
            multi_entry_cd: 'A',
            job_id: 5,
            event_id: 'abcdef'})
      end
      it_behaves_like 'it has a non-empty array of ClassCalendarQueue entries'
      it 'has tammis default alternateid from fake Oracle' do
        json = JSON.parse(subject[0].event_data)
        expect(json['attendees'][0]['email']).to eq 'tammi.chang.clc@gmail.com'
      end
      it 'returns the event_id of a logged entry from a previous run' do
        expect(subject[0].event_id).to eq 'abcdef'
      end
    end
    context 'when the user whitelist has an enrolled student on it with an alternate email for test purposes', if: Calendar::Queries.test_data? do
      before do
        Calendar::User.create({uid: '300939', alternate_email: 'ctweney@testg.berkeley.edu.test-google-a.com'})
      end
      it_behaves_like 'it has a non-empty array of ClassCalendarQueue entries'
      it 'has the meeting place and times for a multi-scheduled Biology 1a' do
        json = JSON.parse(subject[0].event_data)
        expect(json['location']).to eq 'VALLEY LSB 2030'
        expect(json['start']['dateTime']).to eq '2013-09-02T16:00:00.000-07:00'
        expect(json['end']['dateTime']).to eq '2013-09-02T17:00:00.000-07:00'
        expect(json['recurrence'][0]).to eq 'RRULE:FREQ=WEEKLY;UNTIL=20131214T075959Z;BYDAY=MO'
        expect(json['attendees'].length).to eq 1
        expect(json['attendees'][0]['email']).to eq 'ctweney@testg.berkeley.edu.test-google-a.com'
        expect(subject[0].multi_entry_cd).to eq 'A'

        json = JSON.parse(subject[1].event_data)
        expect(json['location']).to eq 'EVANS 60'
        expect(json['start']['dateTime']).to eq '2013-09-04T14:00:00.000-07:00'
        expect(json['end']['dateTime']).to eq '2013-09-04T15:00:00.000-07:00'
        expect(json['recurrence'][0]).to eq 'RRULE:FREQ=WEEKLY;UNTIL=20131214T075959Z;BYDAY=WE'
        expect(json['attendees'].length).to eq 1
        expect(json['attendees'][0]['email']).to eq 'ctweney@testg.berkeley.edu.test-google-a.com'
        expect(subject[1].multi_entry_cd).to eq 'B'
      end
      it 'has the meeting place and times for Biology 1a' do
        expect(JSON.parse(subject[2].event_data)['location']).to eq 'VALLEY LSB 2030'
        expect(subject[2].multi_entry_cd).to eq ''
      end
    end
    context 'when a course exists but its term cant be found' do
      before do
        Calendar::Queries.stub(:get_all_courses).and_return([{
                                                               'term_yr' => 5070,
                                                               'term_cd' => 'B',
                                                               'course_cntl_num' => 12345
                                                             }])
      end
      it 'produces an empty list of entries' do
        expect(subject).to be_empty
      end

    end
  end

end
