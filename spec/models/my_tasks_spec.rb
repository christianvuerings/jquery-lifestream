require "spec_helper"

describe "MyTasks" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_google_proxy = GoogleProxy.new({fake: true})
    @fake_google_tasks_array = @fake_google_proxy.tasks_list()
    @fake_canvas_proxy = CanvasProxy.new({fake: true})
  end

  it "should load nicely with the pre-recorded fake Google and Canvas proxy feeds using the server's timezone" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    CanvasProxy.stub(:access_granted?).and_return(true)
    GoogleProxy.stub(:new).and_return(@fake_google_proxy)
    CanvasProxy.stub(:new).and_return(@fake_canvas_proxy)
    my_tasks_model = MyTasks.new(@user_id, Date.new(2012, 11, 27).to_time_in_current_zone)
    valid_feed = my_tasks_model.get_feed
    valid_feed["sections"].length.should == 4
    valid_feed["sections"][0]["title"].should == "Due"
    valid_feed["sections"][0]["tasks"].size.should == 3
    valid_feed["sections"][1]["title"].should == "Due Tomorrow"
    valid_feed["sections"][1]["tasks"].size.should == 0
    valid_feed["sections"][2]["title"].should == "Upcoming"
    valid_feed["sections"][2]["tasks"].size.should == 4
    valid_feed["sections"][3]["title"].should == "Unscheduled"
    valid_feed["sections"][3]["tasks"].size.should == 1
    valid_feed["sections"].each do |section|
      section["tasks"].each do |task|
        task["title"].blank?.should == false
        task["source_url"].blank?.should == false

        if task["emitter"] == "Google Tasks"
          task["link_url"].should == "https://mail.google.com/tasks/canvas?pli=1"
          task["class"].should == "class2"
          if task["due_date"]
            task["due_date"]["date_string"] =~ /\d\d\/\d\d/
            task["due_date"]["epoch"].should >= 1351641600
          end
        end
        if task["emitter"] == CanvasProxy::APP_ID
          task["link_url"].should =~ /https:\/\/ucberkeley.instructure.com\/courses/
          task["link_url"].should == task["source_url"]
          task["color_class"].should == "class1"
          task["due_date"]["date_string"] =~ /\d\d\/\d\d/
          task["due_date"]["epoch"].should >= 1354060800
        end
      end
    end
  end

  it "should shift tasks into different buckets with a different timezone " do
    #(since Berkeley assignments are probably always due at -0800, irregardless of where the student is)
    old_time_zone = Time.zone
    Time.zone = 13.hours

    GoogleProxy.stub(:access_granted?).and_return(true)
    CanvasProxy.stub(:access_granted?).and_return(true)
    GoogleProxy.stub(:new).and_return(@fake_google_proxy)
    CanvasProxy.stub(:new).and_return(@fake_canvas_proxy)
    my_tasks_model = MyTasks.new(@user_id, Date.new(2012, 11, 27).to_time_in_current_zone)
    valid_feed = my_tasks_model.get_feed
    valid_feed["sections"][0]["title"].should == "Due"
    valid_feed["sections"][0]["tasks"].size.should == 1
    valid_feed["sections"][1]["title"].should == "Due Tomorrow"
    valid_feed["sections"][1]["tasks"].size.should == 2
    valid_feed["sections"][2]["title"].should == "Upcoming"
    valid_feed["sections"][2]["tasks"].size.should == 4
    valid_feed["sections"][3]["title"].should == "Unscheduled"
    valid_feed["sections"][3]["tasks"].size.should == 1

    Time.zone = old_time_zone

  end
end
