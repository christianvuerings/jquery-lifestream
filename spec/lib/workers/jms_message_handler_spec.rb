require "spec_helper"

describe JmsMessageHandler do

  before do
    @reg_status_processor = double("RegStatusEventProcessor")
    @reg_status_processor.stub(:process) { true }
    @final_grades_processor = double("FinalGradesEventProcessor")
    @final_grades_processor.stub(:process) { true }

    @handler = JmsMessageHandler.new [@reg_status_processor, @final_grades_processor]
    @messages = []
    File.open("#{Rails.root}/fixtures/jms_recordings/ist_jms.txt", 'r').each("\n\n") do |msg_yaml|
      msg = YAML::load(msg_yaml)
      @messages.push msg
    end
  end

  it "should do nothing with an empty message" do
    @handler.handle({})
  end

  it "should process a fake test jms message" do
    @reg_status_processor.should_receive(:process)
    @final_grades_processor.should_receive(:process)
    @handler.handle @messages[0]
  end

end
