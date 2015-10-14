require 'spec_helper'

describe Finaid::Merged do
  let!(:oski_uid) { '61889' }
  let!(:non_student_uid) { '212377' }

  shared_examples 'an empty feed' do
    it 'should be empty' do
      expect(subject[:activities]).to eq []
    end
  end

  describe 'non 2xx states' do

    before {
      Settings.myfinaid_proxy.fake = false
    }
    after {
      Settings.myfinaid_proxy.fake = true
    }

    context 'non-student finaid' do
      subject { Finaid::Merged.new(non_student_uid).get_feed }
      it_should_behave_like 'an empty feed'
    end

    context 'student finaid with remote problems' do

      subject { Finaid::Merged.new(oski_uid).get_feed }

      context 'dead remote proxy (5xx errors)' do
        before(:each) {
          stub_request(:any, /#{Regexp.quote(Settings.myfinaid_proxy.base_url)}.*/).to_raise(Faraday::Error::ConnectionFailed)
        }
        after(:each) { WebMock.reset! }

        it_should_behave_like 'an empty feed'
      end

      context '4xx errors on remote proxy' do
        before(:each) {
          stub_request(:any, /#{Regexp.quote(Settings.myfinaid_proxy.base_url)}.*/).to_return(:status => 403)
        }
        after(:each) { WebMock.reset! }

        it_should_behave_like 'an empty feed'

      end

    end
  end

end
