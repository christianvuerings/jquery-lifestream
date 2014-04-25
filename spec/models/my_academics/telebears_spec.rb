require 'spec_helper'

describe MyAcademics::Telebears do
  let!(:oski_uid){ "61889" }
  let(:non_student_uid) { '212377' }
  let!(:no_telebears_student) { '300939' }
  let!(:empty_student) { '238382' }

  let!(:fake_oski_feed) { Bearfacts::Telebears.new({:user_id => oski_uid, :fake => true}) }
  let!(:fake_no_telebears_student_feed) { Bearfacts::Telebears.new({:user_id => no_telebears_student, :fake => true}) }
  let!(:empty_student_feed) { Bearfacts::Telebears.new({:user_id => empty_student, :fake => true}) }

  shared_examples "empty telebears response" do
    it { should_not be_empty }
    its([:foo]) { should eq('baz') }
    its([:telebears]) { should be_empty }
  end

  context "no telebears appointment student" do
    before(:each) do
      Bearfacts::Telebears.stub(:new).and_return(fake_no_telebears_student_feed)
      Bearfacts::Telebears.any_instance.stub(:lookup_student_id).and_return("22300939")
    end
    subject { MyAcademics::Telebears.new(no_telebears_student).merge(@feed ||= {foo: 'baz'}); @feed }

    # Makes sure that the shared example isn't returning false oks due to an empty feed.
    it { Bearfacts::Telebears.new({user_id: no_telebears_student}).get.should_not be_blank }
    it_behaves_like "empty telebears response"
  end

  context "dead remote proxy (5xx errors)" do
    before(:each) { stub_request(:any, /#{Regexp.quote(Settings.bearfacts_proxy.base_url)}.*/).to_raise(Faraday::Error::ConnectionFailed) }
    after(:each) { WebMock.reset! }

    subject { MyAcademics::Telebears.new(oski_uid).merge(@feed ||= {foo: 'baz'}); @feed }

    it_behaves_like "empty telebears response"
  end

  context "4xx response from bearfacts proxy with non-student" do
    before(:each) { Bearfacts::Telebears.any_instance.stub(:get_feed).and_return({}) }

    subject { MyAcademics::Telebears.new(non_student_uid).merge(@feed ||= {foo: 'baz'}); @feed }

    it_behaves_like "empty telebears response"
  end

  context "2xx responses with fake oski" do
    before(:each) do
      Bearfacts::Telebears.stub(:new).and_return(fake_oski_feed)
      @fake_feed_contents = fake_oski_feed.get
      @fake_feed_body = Nokogiri::XML.parse(@fake_feed_contents[:body])
    end

    context "original fake oski feed" do
      subject { MyAcademics::Telebears.new(oski_uid).merge(@feed ||= {foo: 'baz'}); @feed }

      its([:foo]) { should eq('baz') }
      its([:telebears]) { should_not be_blank }
      it { subject[:telebears][:term].should eq("Fall") }
      it { subject[:telebears][:year].should eq(2013) }
      it { subject[:telebears][:slug].should eq("fall-2013") }
      it { subject[:telebears][:adviser_code_required][:required].should be_true }
      it { subject[:telebears][:adviser_code_required][:message].should_not be_include("CalSO") }
      it { subject[:telebears][:phases].length.should eq(2)}
      it { subject[:semesters].length.should eq(1) }
      it { subject[:semesters][0][:slug].should eq("fall-2013") }
    end

    context "fake oski feed, timezone & server specifice setting tests", testext: true do
      subject { MyAcademics::Telebears.new(oski_uid).merge(@feed ||= {foo: 'baz'}); @feed }

      it { subject[:telebears][:phases].first[:startTime][:epoch].should eq(1365438600) }
      it { subject[:telebears][:phases].first[:endTime][:epoch].should eq(1365525000) }
      it { subject[:telebears][:url].should_not be_blank }
      it "should have the same timezone setting as specified from the server" do
        %w(startTime endTime).each do |key|
          time_string = subject[:telebears][:phases].first[key.to_sym][:dateTime]
          tz_from_string = DateTime.parse(time_string).rfc3339
          server_enforced_tz = Time.zone.parse(time_string).to_datetime.rfc3339
          tz_from_string.should eq(server_enforced_tz)
        end
      end
    end

    context "fake oski feed, advisercode = P" do
      before(:each) do
        code = @fake_feed_body.at_css("telebearsAppointment authReleaseCode")
        code.content = "P"
        @fake_feed_contents[:body] = @fake_feed_body.to_s
        Bearfacts::Telebears.any_instance.stub(:get).and_return(@fake_feed_contents)
      end

      subject { MyAcademics::Telebears.new(oski_uid).merge(@feed ||= {foo: 'baz'}); @feed }

      it { subject[:telebears][:term].should eq("Fall") }
      it { subject[:telebears][:adviser_code_required][:required].should be_false }
      it { subject[:telebears][:phases].length.should eq(2)}
    end

    context "fake oski feed, advisercode = C" do
      before(:each) do
        code = @fake_feed_body.at_css("telebearsAppointment authReleaseCode")
        code.content = "C"
        @fake_feed_contents[:body] = @fake_feed_body.to_s
        Bearfacts::Telebears.any_instance.stub(:get).and_return(@fake_feed_contents)
      end

      subject { MyAcademics::Telebears.new(oski_uid).merge(@feed ||= {foo: 'baz'}); @feed }

      it { subject[:telebears][:term].should eq("Fall") }
      it { subject[:telebears][:adviser_code_required][:required].should be_true }
      it { subject[:telebears][:adviser_code_required][:message].should be_include("CalSO") }
      it { subject[:telebears][:phases].length.should eq(2)}
    end

    context "fake oski feed, advisercode = foo" do
      before(:each) do
        code = @fake_feed_body.at_css("telebearsAppointment authReleaseCode")
        code.content = "foo"
        @fake_feed_contents[:body] = @fake_feed_body.to_s
        Bearfacts::Telebears.any_instance.stub(:get).and_return(@fake_feed_contents)
        Rails.logger.should_receive(:warn).at_least(1).times
      end

      subject { MyAcademics::Telebears.new(oski_uid).merge(@feed ||= {foo: 'baz'}); @feed }

      it { subject[:telebears][:term].should eq("Fall") }
      it { subject[:telebears][:adviser_code_required][:required].should be_false }
      it { subject[:telebears][:phases].length.should eq(2)}
    end

    context "student with feed that exists but doesn't have telebearsAppointments element" do
      before(:each) do
        Bearfacts::Telebears.stub(:new).and_return(empty_student_feed)
        Bearfacts::Telebears.any_instance.stub(:lookup_student_id).and_return(empty_student)
      end
      subject { MyAcademics::Telebears.new(empty_student).merge(@feed ||= {foo: 'baz'}); @feed }

      # Makes sure that the shared example isn't returning false oks due to an empty feed.
      it { Bearfacts::Telebears.new({user_id: empty_student}).get.should_not be_blank }
      it_behaves_like "empty telebears response"
    end

  end
end
