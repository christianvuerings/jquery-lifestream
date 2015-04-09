require "spec_helper"

describe Canvas::BackgroundJob do
  describe '.unique_job_id' do
    it 'returns unique job id based on current time' do
      current_time = Time.at(1383330151.057)
      expect(Time).to receive(:now) { current_time }
      result = Canvas::BackgroundJob.unique_job_id
      expect(result).to eq '1383330151057'
    end
  end

  describe '.find' do
    it "returns the current job object from global storage" do
      job_state = { jobStatus: 'courseCreationCompleted' }
      Rails.cache.write('canvas.courseprovision.1234.123456789', job_state, expires_in: 5.seconds.to_i, raw: true)
      result = Canvas::BackgroundJob.find('canvas.courseprovision.1234.123456789')
      expect(result).to eq job_state
    end

    it 'returns nil if job state not found' do
      result = Canvas::BackgroundJob.find('canvas.courseprovision.1234.123456789')
      result.should be_nil
    end
  end
end
