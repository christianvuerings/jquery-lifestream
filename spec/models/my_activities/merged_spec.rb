require "spec_helper"

describe MyActivities::Merged do
  let!(:user_id) { rand(99999).to_s }
  let(:array_inserter) do
    class ArrayInserter

      def self.append!(uid, activities)
        activities << ["#{self.name} #{uid}"]
      end
    end
    ArrayInserter
  end

  let(:hash_inserter) do
    class HashInserter

      def self.append!(uid, activities)
        activities << Hash[*[self.name, uid]]
      end
    end
    HashInserter
  end

  context "should successfully call append! on all proxies and return a merged result" do
    before(:each) do
      @mangled_activities = described_class.new(user_id)
      @mangled_activities.proxies = [array_inserter, hash_inserter]
    end

    subject { @mangled_activities.get_feed[:activities] }

    it { should_not be_empty }
    it { expect { subject }.to_not raise_exception }
    it { subject.first.should eq(["ArrayInserter #{user_id}"]) }
    it { subject[1].should eq({"HashInserter" => user_id}) }
  end

  context "should fail when one of the proxies fails on append!" do
    before(:each) do
      @badly_mangled_activities = described_class.new(user_id)
      @badly_mangled_activities.proxies = [array_inserter, hash_inserter, Object]
    end

    it { expect { @badly_mangled_activities.get_feed[:activities] }.to raise_exception(NoMethodError) }
  end

end
