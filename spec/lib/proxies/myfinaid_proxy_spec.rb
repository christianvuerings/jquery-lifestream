require 'spec_helper'

describe MyfinaidProxy do

  let(:this_year){ Settings.myfinaid_proxy.test_term_year } # start with 2013!

  let(:live_oski_finaid){ MyfinaidProxy.new({user_id: "61889",  term_year: this_year }).get }
  let(:fake_oski_finaid){ MyfinaidProxy.new({user_id: "61889",  term_year: this_year, fake: true}).get }
  let(:live_non_student){ MyfinaidProxy.new({user_id: '212377', term_year: this_year}).get }

  shared_examples "oski tests" do
    it { subject[:body].should be_present }
    it { subject[:status_code].should eq(200) }
    it "should be valid xml" do
      expect {
        Nokogiri::XML(subject[:body]) { |config| config.strict }
      }.to_not raise_exception
    end
  end

  context "oski live finaid with data", :testext => true do
    it_behaves_like "oski tests" do
      subject { live_oski_finaid }
    end
  end

  context "fake finaid tests" do
    it_behaves_like "oski tests" do
      subject { fake_oski_finaid }
    end

    context "Test-Emeritus live feed with no data" do
      #Never hits VCR so it should be fine for non-testext, but to make sure
      before(:each) { MyfinaidProxy.any_instance.stub(:lookup_student_id).and_return(nil) }
      subject { live_non_student }

      it { subject[:body].should eq("Lookup of student_id for uid 212377 failed, cannot call Myfinaid API") }
      it { subject[:status_code].should eq(400) }
    end
  end

  context "dead remote proxy (5xx errors)" do
    before(:each) { stub_request(:any, /#{Regexp.quote(Settings.myfinaid_proxy.base_url)}.*/).to_raise(Faraday::Error::ConnectionFailed) }
    after(:each) { WebMock.reset! }
    subject { live_oski_finaid }

    it { subject[:body].should eq("Remote server unreachable") }
    it { subject[:status_code].should eq(503) }
  end

  context "4xx errors on remote proxy" do
    before(:each) { stub_request(:any, /#{Regexp.quote(Settings.myfinaid_proxy.base_url)}.*/).to_return(:status => 403) }
    after(:each) { WebMock.reset! }

    subject { live_oski_finaid }
    it { subject[:body].should eq("Connection failed: 403 ") }
    it { subject[:status_code].should eq(500) }
  end
end
