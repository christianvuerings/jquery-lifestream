require 'spec_helper'

describe Cache::LiveUpdatesEnabled do
  class DefaultTestClass < UserSpecificModel
    include Cache::LiveUpdatesEnabled
    def get_feed_internal
      {}
    end
  end
  class DemandingTestClass < UserSpecificModel
    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    def get_feed_internal
      {}
    end
  end
  class JsonLiveUpdatesTestClass < UserSpecificModel
    include Cache::LiveUpdatesEnabled
    include Cache::JsonAddedCacher
    def get_feed_internal
      {}
    end
  end

  let(:id) { random_id }
  describe '#warm_cache' do
    context 'default implementation' do
      subject { DefaultTestClass.new(id) }
      it 'allows normal caching' do
        expect(subject).to receive(:get_feed).with(false)
        subject.warm_cache
      end
    end
    context 'fresh-as-possible implementation' do
      subject { DemandingTestClass.new(id) }
      it 'overrides normal caching' do
        expect(subject).to receive(:get_feed).with(true)
        subject.warm_cache
      end
    end
    context 'JSON-caching implementation' do
      subject { JsonLiveUpdatesTestClass.new(id) }
      it 'overrides normal caching' do
        expect(subject).to receive(:get_feed_as_json).with(false)
        subject.warm_cache
      end
    end
  end

end
