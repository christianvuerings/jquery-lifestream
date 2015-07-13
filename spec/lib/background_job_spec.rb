describe BackgroundJob do
  describe '.unique_job_id' do
    before do
      allow(Time).to receive(:now).and_return Time.at(1383330151.057)
      allow(SecureRandom).to receive(:hex).and_return('67f4b934525501cb', '15fb56bedaa3b437')
    end

    it 'returns unique job id based on current time' do
      result = BackgroundJob.unique_job_id
      expect(result).to eq '1383330151057-67f4b934525501cb'
    end

    it 'raises exception if unique id not found after 15 attempts' do
      allow(SecureRandom).to receive(:hex).and_return('67f4b934525501cb')
      Rails.cache.write('1383330151057-67f4b934525501cb', 'test_payload', expires_in: 3000)
      expect { BackgroundJob.unique_job_id }.to raise_error(RuntimeError, 'Unable to find unique Canvas Background Job ID')
    end
  end

  describe '.find' do
    it 'returns the current job object from global storage' do
      job_state = { jobStatus: 'courseCreationCompleted' }
      Rails.cache.write('Canvas::Egrades.1383330151057-67f4b934525501cb', job_state, expires_in: 5.seconds.to_i, raw: true)
      result = BackgroundJob.find('Canvas::Egrades.1383330151057-67f4b934525501cb')
      expect(result).to eq job_state
    end

    it 'returns nil if job state not found' do
      result = BackgroundJob.find('Canvas::Egrades.1383330151057-67f4b934525501cb')
      result.should be_nil
    end
  end
end
