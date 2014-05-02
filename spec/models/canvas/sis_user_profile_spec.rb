require "spec_helper"

describe Canvas::SisUserProfile do
  let(:user_id)   { Settings.canvas_proxy.test_user_id }
  subject         { Canvas::SisUserProfile.new(:user_id => user_id) }

  context "when canvas user profile api request is unsuccessful" do
    before { subject.stub(:request).and_return(nil) }
    context "when providing canvas user profile hash" do
      it "returns nil" do
        expect(subject.get).to be_nil
      end
    end
  end

  context "when canvas user profile api request succeeds" do
    context "when providing canvas user profile hash" do
      it "returns user profile hash" do
        result = subject.get
        expect(result).to be_an_instance_of Hash
      end
    end
  end

end
