require 'spec_helper'

describe Calendar::Exporter do

  describe '#ship_entries' do

    let!(:queue_entries) {
      entry = Calendar::QueuedEntry.new
      entry.year = 2014
      entry.term_cd = 'D'
      entry.ccn = 1234
      entry.multi_entry_cd = ''
      entry.event_data = {fake: true}.to_json
      entry.save
      [entry]
    }
    let!(:exporter) { Calendar::Exporter.new }

    context 'when shipping entries to Google' do
      let!(:event_id) { random_id }
      before do
        user = Calendar::User.new
        user.uid = '300939'
        user.alternate_email = 'ctweney@testg.berkeley.edu.test-google-a.com'
        user.save

        body = {id: event_id}
        fake_insert_proxy = double(insert_event: double(status: 200, body: body.to_json))
        GoogleApps::EventsInsert.stub(:new).and_return(fake_insert_proxy)
      end

      subject { exporter.ship_entries(queue_entries) }
      it 'should have sent entries to Google' do
        expect(subject).to be_true
        log_entries = Calendar::LoggedEntry.all
        saved = log_entries.first
        expect(saved).to be_present
        expect(saved.job_id).to eq 1
        expect(saved.event_id).to eq event_id

        job = Calendar::Job.all.first
        expect(job).to be_present
        expect(job.total_entry_count).to eq 1
        expect(job.error_count).to eq 0
      end
    end

    context 'when trying to export without proper Google credentials' do
      subject { exporter.ship_entries(queue_entries) }
      it 'should have a recorded an error' do
        expect(subject).to be_true
        log_entries = Calendar::LoggedEntry.all
        saved = log_entries.first
        expect(saved).to be_present
        expect(saved.has_error).to be_true
      end
    end

    context 'when Google connection raises an exception' do
      before do
        fake_insert_proxy = double
        allow(fake_insert_proxy).to receive(:insert_event).and_raise(StandardError)
        GoogleApps::EventsInsert.stub(:new).and_return(fake_insert_proxy)
      end

      subject { exporter.ship_entries(queue_entries) }
      it 'should have a recorded an error' do
        expect(subject).to be_true
        job = Calendar::Job.all.first
        expect(job).to be_present
        expect(job.total_entry_count).to eq 0
        expect(job.error_count).to eq 1
      end
    end
  end
end
