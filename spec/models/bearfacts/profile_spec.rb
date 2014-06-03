require "spec_helper"

describe Bearfacts::Profile do

  it "should get Oski Bear's profile from fake vcr recordings" do
    client = Bearfacts::Profile.new({:user_id => "61889", :fake => true})
    response = client.get
    response.should_not be_nil
    xml_doc = response[:xml_doc]
    xml_doc.should_not be_nil
    xml_doc.css('studentGeneralProfile').should_not be_nil
  end

  it "should fail gracefully on a user whose student_id can't be found" do
    client = Bearfacts::Profile.new({:user_id => "0", :fake => true})
    response = client.get
    response[:body].should == "Lookup of student_id for uid 0 failed, cannot call Bearfacts API"
    response[:statusCode].should == 400
    response[:xml_doc].should be_nil
  end

  it "should get Oski Bear's profile from a real server", :testext => true do
    client = Bearfacts::Profile.new({:user_id => "61889", :fake => false})
    response = client.get
    response.should_not be_nil
  end

  context "connection failure" do
    before(:each) { stub_request(:any, /#{Regexp.quote(Settings.bearfacts_proxy.base_url)}.*/).to_raise(Errno::EHOSTUNREACH) }
    after(:each) { WebMock.reset! }
    it 'returns an error status and a nil XML document' do
      response = Bearfacts::Profile.new({:user_id => "61889", :fake => false}).get
      expect(response[:body]).to eq("Remote server unreachable")
      expect(response[:statusCode]).to be > 500
      expect(response[:xml_doc]).to be_nil
    end
  end

end
