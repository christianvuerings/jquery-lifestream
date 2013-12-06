require "spec_helper"

describe MyClasses do
  let(:user_id)     { rand(99999).to_s }
  let(:courses)     { [ {id: 'BIOLOGY-1A-2013-C'} ] }
  let(:fake_canvas) do
    { classes: [{id: '1023614', emitter: 'bCourses', courses: courses}] }
  end
  let(:fake_sakai) do
    { classes: [{id: '095d5b02-afde-4186-a668-0b84734b1d5c', emitter: 'bSpace', courses: courses}] }
  end
  let(:fake_campus) do
    [{ id: 'BIOLOGY-1A-2013-C', course_code: 'BIOLOGY 1A', term_yr: '2013', term_cd: 'C', dept: 'BIOLOGY', catid: '1A', emitter: 'Campus' }]
  end
  subject           { MyClasses.new(user_id) }

  it "should contain all my Canvas courses which match enrolled sections" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    SakaiProxy.stub(:access_granted?).and_return(false)
    CampusUserCoursesProxy.stub(:access_granted?).and_return(true)
    CanvasUserSites.any_instance.stub(:get_feed).and_return(fake_canvas)
    CampusUserCoursesProxy.any_instance.stub(:get_campus_courses).and_return(fake_campus)
    feed = MyClasses.new(user_id).get_feed
    my_classes = feed[:classes]
    my_classes.size.should == 2
    expect(my_classes.index{|entry| entry[:emitter] == CanvasProxy::APP_NAME && entry[:id] == '1023614'}).to_not be_nil
    expect(my_classes.index{|entry| entry[:emitter] == CampusUserCoursesProxy::APP_ID && entry[:id] == 'BIOLOGY-1A-2013-C'}).to_not be_nil
  end

  it "should return successfully without Canvas or bSpace access" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(false)
    CanvasProxy.should_not_receive(:new)
    SakaiUserSitesProxy.should_not_receive(:new)
    CampusUserCoursesProxy.any_instance.stub(:get_campus_courses).and_return([])
    my_classes = MyClasses.new(user_id).get_feed
    expect(my_classes[:classes].size).to eq 0
  end

  it "should return bSpace course sites for the current term" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiProxy.stub(:access_granted?).and_return(true)
    CampusUserCoursesProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.any_instance.stub(:get_categorized_sites).and_return(fake_sakai)
    CampusUserCoursesProxy.any_instance.stub(:get_campus_courses).and_return(fake_campus)
    feed = MyClasses.new(user_id).get_feed
    my_classes = feed[:classes]
    expect(my_classes.size).to eq 2
    expect(my_classes.index{|entry| entry[:emitter] == SakaiProxy::APP_ID && entry[:id] == '095d5b02-afde-4186-a668-0b84734b1d5c'}).to_not be_nil
    expect(my_classes.index{|entry| entry[:emitter] == CampusUserCoursesProxy::APP_ID && entry[:id] == 'BIOLOGY-1A-2013-C'}).to_not be_nil
  end

  it "should return classes in which I am officially enrolled" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(false)
    CampusUserCoursesProxy.any_instance.stub(:get_campus_courses).and_return(fake_campus)
    my_classes = MyClasses.new(user_id).get_feed
    expect(my_classes[:classes].size).to be > 0
    my_classes[:classes].each do |my_class|
      expect(my_class[:emitter]).to eq "Campus"
      expect(my_class[:course_code]).to_not be_nil
      expect(my_class[:site_url].blank?).to be_false
    end
  end

  it "should return some classes for only instructors", :if => CampusData.test_data? do
    my_classes = MyClasses.new('238382').get_feed
    results = my_classes[:classes].select {|entry| entry[:role] == "Instructor" }
    expect(results.size >= 2).to be_true
    results.each do |my_class|
      expect(my_class[:site_url].blank?).to be_false
    end
  end

  it "should not explode if CampusUserCoursesProxy returns false instead of an array" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(false)
    CampusUserCoursesProxy.any_instance.stub(:get_campus_courses).and_return(false)
    my_classes = MyClasses.new(user_id).get_feed
    my_classes.length.should == 4
  end

  it "should clear user and pseudo user cache" do
    my_classes = MyClasses.new(user_id)
    user_cache_key = MyClasses.cache_key(user_id)
    pseudo_user_cache_key = MyClasses.cache_key(Calcentral::PSEUDO_USER_PREFIX + user_id)
    Rails.cache.write(user_cache_key, 'myclasses cached user value')
    Rails.cache.write(pseudo_user_cache_key, 'myclasses cached pseudo user value')
    MyClasses.new(user_id).expire_cache
    expect(Rails.cache.fetch(user_cache_key)).to eq nil
    expect(Rails.cache.fetch(pseudo_user_cache_key)).to eq nil
  end

end
