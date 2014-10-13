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

  context 'getting real data feed', testext: true do
    subject { real_oski_proxy.get }
    it { should_not be_empty }
    its([:statusCode]) { should eq 200 }
  end

  context 'server 404s' do
    before do
      stub_request(:any, /.*#{advising_uri.hostname}.*/).to_return(status: 404)
      Advising::Proxy.any_instance.stub(:lookup_student_id).and_return(11667051)
    end
    after(:each) { WebMock.reset! }
    subject { real_oski_proxy.get }
    its([:body]) { should eq('No advising data could be found for your account.') }
    its([:statusCode]) { should eq(404) }
  end

end
