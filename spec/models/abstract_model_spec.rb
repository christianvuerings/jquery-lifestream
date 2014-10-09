require "spec_helper"

describe AbstractModel do
  let(:uid) { random_id }
  subject { AbstractModel.new(uid) }

  describe 'cache management' do
    it 'uses forced JSON feed to warm cache by default' do
      expect(subject).to receive(:get_feed_as_json).with(true)
      subject.warm_cache
    end

    describe '#expire' do
      before do
        @cache_keys = Set.new
        allow(Rails.cache).to receive(:delete) do |key, options|
          @cache_keys << key
          expect(options[:force]).to be_truthy
        end
      end
      context 'with separate JSON cache' do
        it 'expires both the raw feed and the JSON version' do
          AbstractModel.expire(uid)
          expect(@cache_keys.size).to eq 2
          expect(@cache_keys).to include AbstractModel.cache_key(uid)
          expect(@cache_keys).to include AbstractModel.cache_key(AbstractModel.json_key(uid))
        end
      end
      context 'without separate JSON cache' do
        before {allow(AbstractModel).to receive(:caches_separate_json?).and_return(false)}
        it 'expires only the default feed key' do
          AbstractModel.expire(uid)
          expect(@cache_keys.size).to eq 1
          expect(@cache_keys).to include AbstractModel.cache_key(uid)
        end
      end
    end

  end

end
