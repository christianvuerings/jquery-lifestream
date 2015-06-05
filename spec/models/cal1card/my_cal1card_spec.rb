require "spec_helper"

describe Cal1card::MyCal1card do

  let!(:oski_uid) { "61889" }
  let!(:fake_proxy) { Cal1card::MyCal1card.new(oski_uid, {fake: true}) }
  let!(:real_oski_proxy) { Cal1card::MyCal1card.new(oski_uid, {fake: false}) }
  before(:each) { Cal1card::MyCal1card.stub(:new).and_return(fake_proxy) }
  subject { Cal1card::MyCal1card.new(oski_uid).get_feed }

  it_behaves_like 'a polite HTTP client'

  context "happy path with fake data" do
    include_context 'Live Updates cache'
    it {
      should_not be_nil
      subject[:cal1cardStatus].should == 'OK'
      subject[:debit].should == '0.8'
      subject[:mealpoints].should == '359.11'
      subject[:mealpointsPlan].should == 'Resident Meal Plan Points'
      subject[:statusCode].should eq 200
    }
  end

  context "it should respect a disabled feature flag" do
    include_context 'Live Updates cache'
    before(:each) { Settings.features.stub(:cal1card).and_return(false) }
    it { subject.length.should == 2 }
  end

  context "server errors" do
    include_context 'short-lived Live Updates cache'
    let (:cal1card_uri) { URI.parse(Settings.cal1card_proxy.base_url) }
    before(:each) { Cal1card::MyCal1card.stub(:new).and_return(real_oski_proxy) }
    after(:each) { WebMock.reset! }

    context "unreachable remote server (connection errors)" do
      before(:each) {
        stub_request(:any, /.*#{cal1card_uri.hostname}.*/).to_raise(Errno::ECONNREFUSED)
      }
      it 'reports an error' do
        expect(subject[:body]).to eq('An error occurred retrieving data for Cal 1 Card. Please try again later.')
        expect(subject[:statusCode]).to eq 503
      end
    end

    context "error on remote server (5xx errors)" do
      let!(:status) { 506 }
      let!(:uid) { oski_uid }
      include_context 'expecting logs from server errors'
      before(:each) { stub_request(:any, /.*#{cal1card_uri.hostname}.*/).to_return(status: status) }

      it 'reports an error' do
        expect(subject[:body]).to eq('An error occurred retrieving data for Cal 1 Card. Please try again later.')
        expect(subject[:statusCode]).to eq 503
      end
    end
  end

end
