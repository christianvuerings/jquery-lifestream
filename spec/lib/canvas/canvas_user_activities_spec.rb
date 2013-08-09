require "spec_helper"

describe CanvasUserActivities do

  before do
    @user_id = Settings.canvas_proxy.test_user_id
    @fake_activity_stream_proxy = CanvasUserActivityStreamProxy.new({fake: true})
    @fake_activity_stream = JSON.parse(@fake_activity_stream_proxy.user_activity.body)
    @fake_time = Time.zone.today.to_time_in_current_zone.to_datetime
  end

  it "should be able to process a normal canvas feed" do
    handler = CanvasUserActivities.new(@user_id)
    activities = handler.get_feed
    activities.instance_of?(Array).should == true
    activities.each do | activity |
      activity[:id].blank?.should_not == true
      activity[:user_id].should == @user_id
      activity[:date][:epoch].is_a?(Integer).should == true
      ['canvas-class', 'canvas-group'].include?(activity[:color_class]).should be_true
      activity[:source].blank?.should_not be_true
      activity[:emitter].should == "bCourses"
      activity[:type].blank?.should_not == true
    end
  end

  it "should merge raw Canvas feed with transformed site feeds" do
    active_stream_feed = [
        {
            id: 1999,
            context_type: 'Course',
            type: 'Message',
            course_id: 1,
            title: 'Assignment created',
            updated_at: @fake_time,
            created_at: @fake_time
        },
        {
            id: 2999,
            context_type: 'Course',
            type: 'Message',
            course_id: 2,
            title: 'Assignment deleted',
            updated_at: @fake_time,
            created_at: @fake_time
        },
        {
            id: 3999,
            context_type: 'Group',
            type: 'Message',
            group_id: 3,
            title: 'Party date',
            updated_at: @fake_time,
            created_at: @fake_time
        },
        {
            id: 4999,
            type: 'Conversation',
            conversation_id: 4,
            title: nil,
            updated_at: @fake_time,
            created_at: @fake_time
        }
    ]
    CanvasUserActivityStreamProxy.stub(:new).and_return(stub_proxy(:user_activity, active_stream_feed))
    canvas_sites_feed = {
        classes: [
            {
                id: '1',
                name: 'Course Code 1',
                short_description: 'Course site name 1',
                site_type: 'course',
                color_class: 'canvas-class'
            }
        ],
        groups: [
            {
                id: '3',
                name: 'Group title 3',
                site_type: 'group',
                color_class: 'canvas-group'
            },
            {
                id: '2',
                name: 'Course-as-group title',
                site_type: 'course',
                color_class: 'canvas-group'
            }
        ]
    }
    CanvasUserSites.any_instance.stub(:get_feed).and_return(canvas_sites_feed)
    activities = CanvasUserActivities.new(@user_id).get_feed
    activities.length.should == 4
    activities.each do | activity |
      activity[:user_id].should == @user_id
      activity[:emitter].should == "bCourses"
      activity[:type].blank?.should_not == true
    end
    enrolled_activity = activities.select{|item| item[:id] == 'canvas_1999'}[0]
    enrolled_activity[:color_class].should == 'canvas-class'
    enrolled_activity[:source].should == 'Course Code 1'
    unofficial_activity = activities.select{|item| item[:id] == 'canvas_2999'}[0]
    unofficial_activity[:color_class].should == 'canvas-group'
    unofficial_activity[:source].should == 'Course-as-group title'
    group_activity = activities.select{|item| item[:id] == 'canvas_3999'}[0]
    group_activity[:color_class].should == 'canvas-group'
    group_activity[:source].should == 'Group title 3'
    siteless_activity = activities.select{|item| item[:id] == 'canvas_4999'}[0]
    siteless_activity[:color_class].should == 'canvas-group'
    siteless_activity[:source].should == 'Canvas'
    siteless_activity[:title].should == 'New/Updated Conversation'
    siteless_activity[:type].should == 'discussion'
  end

  it "should be able to ignore malformed entries from the canvas feed" do
    bad_date_entry = { "id" => @user_id, "user_id" => @user_id, "created_at" => "stone-age"}
    flawed_activity_stream = @fake_activity_stream + [bad_date_entry]
    CanvasUserActivityStreamProxy.stub(:new).and_return(stub_proxy(:user_activity, flawed_activity_stream))
    activities = CanvasUserActivities.new(@user_id).get_feed
    activities.instance_of?(Array).should == true
    # The fake activity stream includes one entry which is filtered out by age.
    activities.size.should == @fake_activity_stream.size - 1
  end

  it "should sometimes have score and instructor message appended to the summary field" do
    # Search for a particular entry in the cassette and make sure it's appended to properly
    CanvasUserActivityStreamProxy.stub(:new).and_return(@fake_activity_stream_proxy)
    activities = CanvasUserActivities.new(@user_id).get_feed
    activity = activities.select {|entry| entry[:id] == "canvas_40544495"}.first
    activity[:summary].should eq("Please write more neatly next time. 87 out of 100 - Good work!")
  end

  it "should strip system generated 'click here' URLs from the summary field" do
    # But should not over-strip by removing instructor-added 'click here' URLs
    CanvasUserActivityStreamProxy.stub(:new).and_return(@fake_activity_stream_proxy)
    activities = CanvasUserActivities.new(@user_id).get_feed

    activity = activities.select {|entry| entry[:id] == "canvas_43225861"}.first
    activity[:summary].should eq("First, some instructor-written text. Click here to view the assignment: https://ucberkeley.instructure.com/courses/832071/assignments/3043635 A new assignment has been created for your course, Biology for Poets Report to STC due: Apr 1 at 11:59pm")

    activity = activities.select {|entry| entry[:id] == "canvas_43395837"}.first
    activity[:summary].should eq("First, some instructor-added text. You can view the submission here: http://example.com?p=123 Oski Bear has just turned in a late submission for Tibullus paper in the course Biology for Poets")
  end

end
