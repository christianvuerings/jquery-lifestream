require 'spec_helper'

describe DelayedCacheCleaner do

  let(:cleaner) { DelayedCacheCleaner.new }

  context "queuing up a key for deletion" do
    before {
      Calcentral::Messaging.should_receive(:publish).with(
        "/queues/delayed_cache_cleaner",
        {"cache_key" => "akey",
         "delay" => 3
        })
    }
    subject { DelayedCacheCleaner.queue("akey", 3) }
    it { should be_true }
  end

  context "queueing up an empty key should do nothing" do
    before {
      Calcentral::Messaging.should_not_receive(:publish).with(any_args)
    }
    subject { DelayedCacheCleaner.queue("", 3) }
    it { should be_nil }
  end

  context "processing a delayed-deletion message" do
    before {
      Rails.cache.should_receive(:delete).with("akey", {:force => true})
    }
    subject { cleaner.on_message({"cache_key" => "akey", "delay" => 1}) }
    it {
      subject.join
      subject.should_not be_nil
    }

  end

end
