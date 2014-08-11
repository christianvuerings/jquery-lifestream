require 'spec_helper'

describe Advising::Proxy do

  let (:fake_oski_proxy) { Advising::Proxy.new({user_id: '61889', fake: true}) }
  let (:real_oski_proxy) { Advising::Proxy.new({user_id: '61889', fake: false}) }
  let (:advising_uri) { URI.parse(Settings.advising_proxy.base_url) }

  context 'fetching fake data feed' do
    subject { fake_oski_proxy.get }
    it { should_not be_empty }
  end

  context 'checking the fake feed for correct json' do
    subject { fake_oski_proxy.get }
    it {
      subject[:name].should == 'Oski Bear'
    }
  end

  context 'with a non-student' do
    before do
      Advising::Proxy.any_instance.stub(:lookup_student_id).and_return(nil)
    end
    subject { fake_oski_proxy.get }
    it 'should return empty response' do
      subject.should be_empty
    end
  end

  context 'proper caching behaviors' do
    include_context 'it writes to the cache'
    before do
      Advising::Proxy.any_instance.stub(:lookup_student_id).and_return(11667051)
    end
    it 'should write to cache' do
      fake_oski_proxy.get
    end
  end

  context 'getting real data feed', testext: true do
    subject { real_oski_proxy.get }
    it { should_not be_empty }
    its([:statusCode]) { should eq 200 }
  end

  context 'server errors' do
    include_context 'short-lived cache write of Hash on failures'
    after(:each) { WebMock.reset! }
    subject { real_oski_proxy.get }

    context 'unreachable remote server (connection errors)' do
      before do
        stub_request(:any, /.*#{advising_uri.hostname}.*/).to_raise(Errno::ECONNREFUSED)
        Advising::Proxy.any_instance.stub(:lookup_student_id).and_return(11667051)
      end
      its([:body]) { should eq('An error occurred retrieving data for Advisor Appointments. Please try again later.') }
      its([:statusCode]) { should eq(503) }
    end

    context 'error on remote server (5xx errors)' do
      before do
        stub_request(:any, /.*#{advising_uri.hostname}.*/).to_return(status: 506)
        Advising::Proxy.any_instance.stub(:lookup_student_id).and_return(11667051)
      end
      its([:body]) { should eq('An error occurred retrieving data for Advisor Appointments. Please try again later.') }
      its([:statusCode]) { should eq(506) }
    end
  end

  context 'proxy should respect a disabled feature flag' do
    before do
      Settings.features.stub(:advising).and_return(false)
    end
    subject { real_oski_proxy.get }
    it { should eq({}) }
  end

end
