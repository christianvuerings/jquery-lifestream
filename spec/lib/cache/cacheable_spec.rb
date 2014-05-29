require "spec_helper"

describe Cache::Cacheable do
  class TestCacheable
    extend Cache::Cacheable

    def self.cache_key id
      id
    end
  end

  context "with nil values" do
    let(:randkey) { rand(99999).to_s }
    describe '#fetch_from_cache' do
      before do
        expect(Rails.cache).to receive(:write).once.with(randkey, NilClass, anything).and_call_original
        expect(Rails.cache).to receive(:fetch).twice.with(randkey, anything).and_call_original
      end
      it 'translates nil' do
        first_val = TestCacheable.fetch_from_cache randkey do
          nil
        end
        expect(first_val).to be_nil
        second_val = TestCacheable.fetch_from_cache randkey do
          'something else'
        end
        expect(second_val).to be_nil
      end
    end
  end

end
