require "spec_helper"

describe "MyTasks" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_google_proxy = GoogleProxy.new({fake: true})
    @fake_google_tasks_array = @fake_google_proxy.tasks_list()
  end

  it "should load nicely with the pre-recorded fake Google proxy feed for tasks#list" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleProxy.stub(:new).and_return(@fake_google_proxy)
    GoogleProxy.any_instance.stub(:events_list).and_return(@fake_google_tasks_array)
    valid_feed = MyTasks.get_feed(@user_id, Date.new(2012, 11, 27))
    valid_feed["sections"].length.should == 4
    valid_feed["sections"][0]["title"].should == "Due"
    valid_feed["sections"][0]["tasks"].size.should == 1
    #valid_feed["sections"][1]["title"].should == "Due Tomorrow"
    #valid_feed["sections"][1]["tasks"].size.should == 1
    valid_feed["sections"][2]["title"].should == "Upcoming"
    valid_feed["sections"][2]["tasks"].size.should == 3
    valid_feed["sections"][3]["title"].should == "Unscheduled"
    valid_feed["sections"][3]["tasks"].size.should == 1
    valid_feed["sections"].each do |section|
      section["tasks"].each do |task|
        task["link_url"].blank?.should == false
        if task["emitter"] == "Google Tasks"
          task["class"] == "class2"
        end
      end
    end
  end

end