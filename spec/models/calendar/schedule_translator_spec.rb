require 'spec_helper'

describe Calendar::ScheduleTranslator do

  describe '#recurrence_rule' do
    subject { Calendar::ScheduleTranslator.new(schedule, term).recurrence_rule }
    let(:schedule) { '' }
    let(:term) {
      term = Berkeley::Terms.fetch.campus['fall-2013']
    }

    context 'decoding Oracle meeting_days to RRULE' do
      let(:schedule) { {'meeting_days' => ' M W F'} }
      it 'produces a correct RRULE for MWF' do
        expect(subject).to eq "RRULE:FREQ=WEEKLY;UNTIL=20131207T075959Z;BYDAY=MO,WE,FR"
      end
    end

    context 'decoding a class that meets every day' do
      let(:schedule) { {'meeting_days' => 'SMTWTFS'} }
      it 'produces a correct RRULE for all 7 days' do
        expect(subject).to eq "RRULE:FREQ=WEEKLY;UNTIL=20131207T075959Z;BYDAY=SU,MO,TU,WE,TH,FR,SA"
      end
    end

    context 'handling an empty input' do
      it 'returns nil when given nil' do
        expect(subject).to be_nil
      end
    end

    context 'handling an input of all spaces' do
      let(:schedule) { {'meeting_days' => '         '} }
      it 'returns nil when given all spaces' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#times' do
    let (:mwf_class) { {
      'meeting_days' => ' M W F',
      'meeting_start_time' => '0237',
      'meeting_start_time_ampm_flag' => 'P',
      'meeting_end_time' => '0337',
      'meeting_end_time_ampm_flag' => 'P'
    } }
    let (:mw_class) { {
      'meeting_days' => ' M W',
      'meeting_start_time' => '1001',
      'meeting_start_time_ampm_flag' => 'A',
      'meeting_end_time' => '1130',
      'meeting_end_time_ampm_flag' => 'A'
    } }
    let (:thursday_class) { {
      'meeting_days' => '    T',
      'meeting_start_time' => '1100',
      'meeting_start_time_ampm_flag' => 'P',
      'meeting_end_time' => '1159',
      'meeting_end_time_ampm_flag' => 'P'
    } }
    let (:sunday_class) { {
      'meeting_days' => 'SM   ',
      'meeting_start_time' => '0237',
      'meeting_start_time_ampm_flag' => 'A',
      'meeting_end_time' => '0157',
      'meeting_end_time_ampm_flag' => 'P'
    } }
    let (:saturday_class) { {
      'meeting_days' => '      S',
      'meeting_start_time' => '1200',
      'meeting_start_time_ampm_flag' => 'P',
      'meeting_end_time' => '1230',
      'meeting_end_time_ampm_flag' => 'P'
    } }

    subject { Calendar::ScheduleTranslator.new(schedule, term).times }
    context 'a term that starts on a Thursday' do

      let(:term) {
        # fall 2013 started on a Thursday.
        term = Berkeley::Terms.fetch.campus['fall-2013']
      }

      context 'a MWF class' do
        let(:schedule) { mwf_class }
        it 'its first meeting should be on Friday' do
          expect(subject[:start]).to eq DateTime.parse('2013-08-30T14:37:00-07:00')
          expect(subject[:end]).to eq DateTime.parse('2013-08-30T15:37:00-07:00')
        end
      end

      context 'a MW class' do
        let(:schedule) { mw_class }
        it 'its first meeting should be on Monday' do
          expect(subject[:start]).to eq DateTime.parse('2013-09-02T10:01:00-07:00')
          expect(subject[:end]).to eq DateTime.parse('2013-09-02T11:30:00-07:00')
        end
      end

      context 'a Thursday class' do
        let(:schedule) { thursday_class }
        it 'its first meeting should be on Thursday' do
          expect(subject[:start]).to eq DateTime.parse('2013-08-29T23:00:00-07:00')
          expect(subject[:end]).to eq DateTime.parse('2013-08-29T23:59:00-07:00')
        end
      end

      context 'a Sunday class' do
        let(:schedule) { sunday_class }
        it 'its first meeting should be on Sunday' do
          expect(subject[:start]).to eq DateTime.parse('2013-09-01T02:37:00-07:00')
          expect(subject[:end]).to eq DateTime.parse('2013-09-01T13:57:00-07:00')
        end
      end

      context 'a Saturday class' do
        let(:schedule) { saturday_class }
        it 'its first meeting should be on Saturday' do
          expect(subject[:start]).to eq DateTime.parse('2013-08-31T12:00:00-07:00')
          expect(subject[:end]).to eq DateTime.parse('2013-08-31T12:30:00-07:00')
        end
      end

    end

    context 'a term that starts on a Sunday' do

      let(:term) {
        Berkeley::Term.new(
          {
            'term_cd' => 'B',
            'term_yr' => 2013,
            'term_name' => 'FAKE',
            'term_start_date' => '2013-09-01T00:00:00-07:00',
            'term_end_date' => '2013-12-05T00:00:00-07:00'
          })
      }

      context 'a MWF class' do
        let(:schedule) { mwf_class }
        it 'its first meeting should be on Monday' do
          expect(subject[:start]).to eq DateTime.parse('2013-09-02T14:37:00-07:00')
          expect(subject[:end]).to eq DateTime.parse('2013-09-02T15:37:00-07:00')
        end
      end

      context 'a MW class' do
        let(:schedule) { mw_class }
        it 'its first meeting should be on Monday' do
          expect(subject[:start]).to eq DateTime.parse('2013-09-02T10:01:00-07:00')
          expect(subject[:end]).to eq DateTime.parse('2013-09-02T11:30:00-07:00')
        end
      end

      context 'a Thursday class' do
        let(:schedule) { thursday_class }
        it 'its first meeting should be on Thursday' do
          expect(subject[:start]).to eq DateTime.parse('2013-09-05T23:00:00-07:00')
          expect(subject[:end]).to eq DateTime.parse('2013-09-05T23:59:00-07:00')
        end
      end

      context 'a Sunday class' do
        let(:schedule) { sunday_class }
        it 'its first meeting should be on Sunday' do
          expect(subject[:start]).to eq DateTime.parse('2013-09-01T02:37:00-07:00')
          expect(subject[:end]).to eq DateTime.parse('2013-09-01T13:57:00-07:00')
        end
      end

      context 'a Saturday class' do
        let(:schedule) { saturday_class }
        it 'its first meeting should be on Saturday' do
          expect(subject[:start]).to eq DateTime.parse('2013-09-07T12:00:00-07:00')
          expect(subject[:end]).to eq DateTime.parse('2013-09-07T12:30:00-07:00')
        end
      end

    end

  end
end
