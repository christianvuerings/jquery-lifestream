require 'spec_helper'

describe Advising::MyAdvising do
  let (:fake_oski_proxy) { Advising::Proxy.new({user_id: '61889', fake: true}) }
  let (:real_oski_proxy) { Advising::Proxy.new({user_id: '61889', fake: false}) }
  let (:advising_uri) { URI.parse(Settings.advising_proxy.base_url) }
  let(:proxy) { real_oski_proxy }
  before do
    allow(proxy).to receive(:lookup_student_id).and_return(11667051)
    allow(Advising::Proxy).to receive(:new).and_return(proxy)
  end
  subject { Advising::MyAdvising.new('61889') }

  context 'proper caching behaviors' do
    let(:proxy) { fake_oski_proxy }
    include_context 'Live Updates cache'
    it 'should write to cache' do
      subject.get_feed
    end
  end

  context 'server 404s' do
    include_context 'Live Updates cache'
    before do
      stub_request(:any, /.*#{advising_uri.hostname}.*/).to_return(status: 404)
    end
    after { WebMock.reset! }
    it 'should write to cache' do
      subject.get_feed
    end
  end

  context 'server errors' do
    include_context 'short-lived Live Updates cache'
    after(:each) { WebMock.reset! }

    context 'unreachable remote server (connection errors)' do
      before do
        stub_request(:any, /.*#{advising_uri.hostname}.*/).to_raise(Errno::ECONNREFUSED)
      end
      it 'reports an error' do
        feed = subject.get_feed
        expect(feed[:body]).to eq('Failed to connect with your department\'s advising system.')
        expect(feed[:statusCode]).to eq 503
      end
    end

    context 'error on remote server (5xx errors)' do
      before do
        stub_request(:any, /.*#{advising_uri.hostname}.*/).to_return(status: 506)
      end
      it 'reports an error' do
        feed = subject.get_feed
        expect(feed[:body]).to eq('Failed to connect with your department\'s advising system.')
        expect(feed[:statusCode]).to eq 506
      end
    end
  end

  context 'disabled feature flag' do
    include_context 'Live Updates cache'
    before do
      Settings.features.stub(:advising).and_return(false)
    end
    it 'returns an empty feed' do
      feed = subject.get_feed
      expect(feed[:name]).to be_nil
      expect(feed[:body]).to be_nil
    end
  end

end
