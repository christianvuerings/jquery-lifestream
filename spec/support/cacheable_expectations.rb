shared_context 'it writes to the cache' do
  before do
    Rails.cache.should_receive(:write)
  end
end

shared_context 'short-lived cache write of NilClass on failures' do
  before do
    Rails.cache.should_receive(:write).with(
      an_instance_of(String),
      NilClass,
      {expires_in: Settings.cache.expiration.failure, force: true})
  end
end

shared_context 'short-lived cache write of Hash on failures' do
  before do
    Rails.cache.should_receive(:write).with(
      an_instance_of(String),
      an_instance_of(Hash),
      {expires_in: Settings.cache.expiration.failure, force: true})
  end
end

shared_context 'Live Updates cache' do
  before do
    Rails.cache.should_receive(:write).with(/LastModified/, anything, anything).twice.ordered
    Rails.cache.should_receive(:write).with(/FeedChangedRateLimiter/, anything, anything).ordered
    Rails.cache.should_receive(:write).with(/#{described_class.name}/, an_instance_of(Hash), an_instance_of(Hash)).ordered
  end
end

shared_context 'short-lived Live Updates cache' do
  before do
    Rails.cache.should_receive(:write).with(/LastModified/, anything, anything).twice.ordered
    Rails.cache.should_receive(:write).with(/FeedChangedRateLimiter/, anything, anything).ordered
    Rails.cache.should_receive(:write).with(/#{described_class.name}/, an_instance_of(Hash),
      {expires_in: Settings.cache.expiration.failure, force: true}).ordered
  end
end
