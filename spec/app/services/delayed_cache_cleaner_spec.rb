require 'spec_helper'

describe DelayedCacheCleaner do

  let(:cleaner) { DelayedCacheCleaner.new({"key" => "mykey"}).run }

  context "making a normal call to the cleaner" do
    before { Rails.cache.should_receive(:delete).with(any_args) }
    subject { cleaner }
    it { should be_nil }
  end

  context "queueing up a key when torquebox isn't available" do
    before {
      TorqueBox::ScheduledJob.should_not_receive(:at)
    }
    subject { DelayedCacheCleaner.queue("akey", 10) }
    it { should be_nil }
  end

  context "queueing up a key for delayed deletion" do
    before {
      ENV['IS_TORQUEBOX'] = "true"
      TorqueBox::ScheduledJob.should_receive(:at).with("DelayedCacheCleaner", {:in => 10, :config => {"key" => "akey"}})
    }
    subject { DelayedCacheCleaner.queue("akey", 10) }
    it { should be_nil }
    after {
      ENV['IS_TORQUEBOX'] = nil
    }
  end

  context "queueing up a key for default delayed deletion" do
    before {
      TorqueBox::ScheduledJob.should_receive(:at).with("DelayedCacheCleaner", {:in => 5000, :config => {"key" => "akey"}})
      ENV['IS_TORQUEBOX'] = "true"
    }
    subject { DelayedCacheCleaner.queue "akey" }
    it { should be_nil }
    after {
      ENV['IS_TORQUEBOX'] = nil
    }
  end

end
