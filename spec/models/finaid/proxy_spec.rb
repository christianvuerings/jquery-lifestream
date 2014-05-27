require 'spec_helper'

describe Finaid::Proxy do

  let(:this_year){ 2013 }

  let(:live_oski_finaid){ Finaid::Proxy.new({user_id: "61889",  term_year: this_year }).get }
  let(:fake_oski_finaid){ Finaid::Proxy.new({user_id: "61889",  term_year: this_year, fake: true}).get }
  let(:live_non_student){ Finaid::Proxy.new({user_id: '212377', term_year: this_year}).get }

  shared_examples "oski tests" do
    it { subject[:body].should be_present }
    it { subject[:statusCode].should eq(200) }
    it "should be valid xml" do
      expect {
        Nokogiri::XML(subject[:body]) { |config| config.strict }
      }.to_not raise_exception
    end
  end

  context "oski live finaid with data", :testext => true, :ignore => true do
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
      before(:each) { Finaid::Proxy.any_instance.stub(:lookup_student_id).and_return(nil) }
      subject { live_non_student }

      it { subject[:body].should eq("Lookup of student_id for uid 212377 failed, cannot call Myfinaid API") }
      it { subject[:statusCode].should eq(400) }
    end
  end

end
