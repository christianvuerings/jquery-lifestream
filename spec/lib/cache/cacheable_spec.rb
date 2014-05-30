require "spec_helper"

describe Cache::Cacheable do
  class TestCacheable
    extend Cache::Cacheable

    def self.cache_key id
      id
    end
  end

  let(:randkey) { rand(99999).to_s }

  context 'with nil values' do
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

  context 'smart fetch' do
    context 'with normal hash values' do
      let(:normal_hash) { {foo: 'bar'} }
      context 'when no exceptions occur' do
        before do
          expect(Rails.cache).to receive(:read).twice.with(randkey).and_call_original
          expect(Rails.cache).to receive(:write).once.with(
                                   randkey,
                                   normal_hash,
                                   {expires_in: Settings.cache.expiration.default, force: true}
                                 ).and_call_original
        end
        it 'caches a hash' do
          first_val = TestCacheable.smart_fetch_from_cache({id: randkey}) do
            normal_hash
          end
          expect(first_val).to eq normal_hash
          second_val= TestCacheable.smart_fetch_from_cache({id: randkey}) do
            normal_hash
          end
          expect(second_val).to eq normal_hash
        end
      end
    end
  end

end

