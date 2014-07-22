require "spec_helper"

describe Canvas::Synchronization do
  before { Canvas::Synchronization.create(:last_guest_user_sync => 1.weeks.ago.utc) }

  describe "#get" do
    it "raises exception if no record exists" do
      Canvas::Synchronization.delete_all
      expect(Canvas::Synchronization.count).to eq 0
      expect { Canvas::Synchronization.get }.to raise_error(RuntimeError, "Canvas synchronization data is missing")
    end

    it "returns primary synchronization record" do
      result = Canvas::Synchronization.get
      expect(result).to be_an_instance_of Canvas::Synchronization
      expect(result.last_guest_user_sync).to be_an_instance_of ActiveSupport::TimeWithZone
    end
  end
end
