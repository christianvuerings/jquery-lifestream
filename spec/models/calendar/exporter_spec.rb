require 'spec_helper'

describe Calendar::Exporter do

  describe '#ship_entries' do
    let(:exporter) { Calendar::Exporter.new }

    let!(:queue_entries) {
      entry = Calendar::QueuedEntry.create(
        {
          year: 2014,
          term_cd: 'D',
          ccn: 1234,
          multi_entry_cd: '',
          event_data: {fake: true}.to_json})
      [entry]
    }

    context 'when Google connection raises an exception' do
      before do
        fake_insert_proxy = double
        allow(fake_insert_proxy).to receive(:queue_event)
        allow(fake_insert_proxy).to receive(:run_batch).and_raise(StandardError)
        GoogleApps::EventsBatchInsert.stub(:new).and_return(fake_insert_proxy)
      end

      subject { exporter.ship_entries(queue_entries) }
      it 'should have a recorded an error' do
        expect(subject).to be_truthy
        job = Calendar::Job.all.first
        expect(job).to be_present
        expect(job.total_entry_count).to eq 0
        expect(job.error_count).to eq 1
      end
    end
  end
end
