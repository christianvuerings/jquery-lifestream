describe Cache::JsonAddedCacher do
  class JsonCachingTestClass
    include Cache::CachedFeed
    include Cache::JsonAddedCacher
    def get_feed_internal
      {}
    end
    def instance_key
      'sid'
    end
  end
  subject { JsonCachingTestClass.new }

  it 'caches the JSON version of the feed' do
    expect(subject).to receive(:get_feed_as_json).twice.and_call_original
    expect(subject).to receive(:get_feed).once.and_call_original
    subject.get_feed_as_json
    subject.get_feed_as_json
  end

  it 'expires the JSON cache as well as the original feed' do
    expect(Rails.cache).to receive(:delete).twice.and_call_original
    JsonCachingTestClass.expire 'sid'
  end

end
