require 'spec_helper'

describe CanvasCourseProvisionController do

  let(:uid) { rand(99999).to_s }
  let(:admin_acting_as) { '35904' }
  let(:admin_term_slug) { 'spring-2014' }
  let(:admin_by_ccns) { ['76376', '76628'] }
  let(:canvas_course_id) { rand(99999).to_s }
  let(:fake_provisioning_feed) do
    {
      'is_admin' => false,
      'admin_acting_as' => nil,
      'admin_semesters' => nil,
      'teachingSemesters' => {},
    }
  end
  before do
    session['user_id'] = uid
  end

  describe '#get_feed' do
    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { get :get_feed }
    end
    context 'when user authenticated' do
      before do
        allow_any_instance_of(Canvas::CourseProvision).to receive(:get_feed).and_return(fake_provisioning_feed)
        allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_create_canvas_course_site?).and_return(fake_authorized)
      end
      context 'allowed to create a course site' do
        let(:fake_authorized) {true}
        it 'should return sections feed' do
          get :get_feed
          assert_response :success
          json_response = JSON.parse(response.body)
          expect(json_response).to eq fake_provisioning_feed
        end
        it 'should not accept a canvas_course_id parameter' do
          get :get_feed, canvas_course_id: canvas_course_id
          assert_response 500
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to be_present
        end
        it_should_behave_like "an api endpoint" do
          before { allow_any_instance_of(Canvas::CourseProvision).to receive(:get_feed).and_raise(RuntimeError, "Something went wrong") }
          let(:make_request) { get :get_feed }
        end
        it 'should respond with empty 401 response when feed is empty' do
          allow_any_instance_of(Canvas::CourseProvision).to receive(:get_feed).and_return(nil)
          get :get_feed
          assert_response 401
          expect(response.body).to eq " "
        end
      end
      context 'not allowed to create a course site' do
        let(:fake_authorized) {false}
        it 'responds with empty 403' do
          get :get_feed
          assert_response 403
          expect(response.body).to be_blank
        end
      end
    end
  end

  describe '#get_sections_feed' do
    let(:fake_sections_feed) do
      fake_provisioning_feed.merge('canvas_course' => {'canvasCourseId' => canvas_course_id.to_i, 'canEdit' => fake_can_edit})
    end
    let(:fake_can_edit) { false }
    let(:fake_course_provision) { instance_double(Canvas::CourseProvision, get_feed: fake_sections_feed) }
    let(:fake_policy) { instance_double(Canvas::CoursePolicy) }
    it_should_behave_like 'a user authenticated api endpoint' do
      let(:make_request) { get :get_sections_feed, canvas_course_id: canvas_course_id }
    end
    context 'when user authenticated' do
      before do
        allow(Canvas::CourseProvision).to receive(:new) do |uid_arg, options|
          if (uid_arg == uid) && (options[:canvas_course_id] == canvas_course_id.to_i)
            fake_course_provision
          end
        end
        allow(Canvas::CoursePolicy).to receive(:new).and_return(fake_policy)
        allow(fake_policy).to receive(:can_view_official_sections?).and_return(fake_authorized)
        allow(fake_policy).to receive(:can_edit_official_sections?).and_return(fake_can_edit)
      end
      context 'allowed to view course site official sections' do
        let(:fake_authorized) { true }
        it 'should return sections feed' do
          get :get_sections_feed, canvas_course_id: canvas_course_id
          assert_response :success
          expect(JSON.parse(response.body)).to eq fake_sections_feed
        end
        context 'in LTI context' do
          before do
            session['canvas_course_id'] = canvas_course_id
          end
          it 'uses the session-stored course ID' do
            get :get_sections_feed, canvas_course_id: 'embedded'
            assert_response :success
            expect(JSON.parse(response.body)).to eq fake_sections_feed
          end
        end
        context 'allowed to edit official sections' do
          let(:fake_can_edit) { true }
          it 'should return sections feed' do
            get :get_sections_feed, canvas_course_id: canvas_course_id
            assert_response :success
            expect(JSON.parse(response.body)).to eq fake_sections_feed
          end
        end
        it 'requires a canvas_course_id parameter' do
          get :get_sections_feed, canvas_course_id: ''
          assert_response 500
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to be_present
        end
        it_should_behave_like "an api endpoint" do
          before { allow(fake_course_provision).to receive(:get_feed).and_raise(RuntimeError, "Something went wrong") }
          let(:make_request) { get :get_sections_feed, canvas_course_id: canvas_course_id }
        end
        context 'when feed is empty' do
          let(:fake_sections_feed) {nil}
          it 'should respond with empty 401' do
            get :get_sections_feed, canvas_course_id: canvas_course_id
            assert_response 401
            expect(response.body).to eq " "
          end
        end
      end
      context 'not allowed to view official sections' do
        let(:fake_authorized) {false}
        it 'responds with empty 403' do
          get :get_sections_feed, canvas_course_id: canvas_course_id
          assert_response 403
          expect(response.body).to be_blank
        end
      end
    end
  end

  describe '#create_course_site' do
    let(:instructor_id) { '1234' }      # represents UID for instructor / teacher creating courses
    let(:ccns) { ['12345', '12348'] }   # represents the course control numbers associated with each course section
    let(:term_slug) { 'fall-2014' }     # represents the term for the course being created
    before do
      allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_create_canvas_course_site?).and_return(true)
    end

    it_should_behave_like "an api endpoint" do
      before { allow_any_instance_of(Canvas::CourseProvision).to receive(:create_course_site).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { post :create_course_site, ccns: ccns, admin_acting_as: instructor_id, term_slug: term_slug }
    end

    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { post :create_course_site, ccns: ccns, admin_acting_as: instructor_id, term_slug: term_slug }
    end

    it 'does not allow a combination of act-as and by-CCNs' do
      post :create_course_site, admin_acting_as: rand(99999).to_s, admin_by_ccns: [rand(99999)], admin_term_slug: 'spring-2014'
      assert_response 500
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq "Conflicting request parameters sent to Canvas Course Provision"
    end

    it 'responds with success when course provisioning job is created' do
      allow_any_instance_of(Canvas::CourseProvision).to receive(:create_course_site).and_return('canvas.courseprovision.12345.1383330151057')
      post :create_course_site, ccns: @ccns, admin_acting_as: @instructor_id, term_slug: @term_slug
      assert_response :success
      json_response = JSON.parse(response.body)
      json_response['job_request_status'].should == 'Success'
      json_response['job_id'].should == 'canvas.courseprovision.12345.1383330151057'
    end
  end

  describe '#edit_sections' do
    let(:fake_can_edit) { false }
    let(:ccns_to_remove) { ['16171', '16109', '10287'] }
    let(:ccns_to_add) { ['16167', '16168', '16169'] }
    it_should_behave_like 'a user authenticated api endpoint' do
      let(:make_request) { post :edit_sections, canvas_course_id: canvas_course_id, ccns_to_remove: ccns_to_remove, ccns_to_add:  ccns_to_add }
    end
    context 'when user authenticated' do
      before do
        allow_any_instance_of(Canvas::CourseProvision).to receive(:edit_sections).and_return('canvas.courseprovision.12345.1383330151057')
        allow_any_instance_of(Canvas::CoursePolicy).to receive(:can_edit_official_sections?).and_return(fake_can_edit)
      end
      context 'allowed to edit official sections' do
        let(:fake_can_edit) { true }
        it 'responds with success when section removal job is created' do
          post :edit_sections, canvas_course_id: canvas_course_id, ccns_to_remove: ccns_to_remove, ccns_to_add:  ccns_to_add
          assert_response :success
          json_response = JSON.parse(response.body)
          json_response['job_request_status'].should == 'Success'
          json_response['job_id'].should == 'canvas.courseprovision.12345.1383330151057'
        end
        it_should_behave_like 'an api endpoint' do
          before { allow_any_instance_of(Canvas::CourseProvision).to receive(:edit_sections).and_raise(RuntimeError, "Something went wrong") }
          let(:make_request) { post :edit_sections, canvas_course_id: canvas_course_id, ccns_to_remove: ccns_to_remove, ccns_to_add:  ccns_to_add }
        end
      end
      context 'not allowed to edit official sections' do
        let(:fake_can_edit) {false}
        it 'responds with empty 403' do
          post :edit_sections, canvas_course_id: canvas_course_id, ccns_to_remove: ccns_to_remove, ccns_to_add:  ccns_to_add
          assert_response 403
          expect(response.body).to be_blank
        end
      end
    end
  end

  describe '#job_status' do
    it_should_behave_like "an api endpoint" do
      before { allow(Canvas::ProvideCourseSite).to receive(:find).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { get :job_status, job_id: 'canvas.courseprovision.12345.1383330151057' }
    end

    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { get :job_status, job_id: 'canvas.courseprovision.12345.1383330151057' }
    end

    it 'returns error if canvas course provisioning job not found' do
      get :job_status, job_id: 'canvas.courseprovision.12345.1383330151057'
      assert_response :success
      json_response = JSON.parse(response.body)
      json_response['job_id'].should == 'canvas.courseprovision.12345.1383330151057'
      json_response['jobStatus'].should == 'jobNotFoundError'
      json_response['error'].should == 'Unable to find course management job'
    end

    it 'returns status of canvas course provisioning job' do
      cpcs = Canvas::ProvideCourseSite.new('1234')
      cpcs.instance_eval { @jobStatus = 'Processing'; @completed_steps = ['Prepared courses list', 'Identified department sub-account'] }
      cpcs.save

      get :job_status, job_id: cpcs.job_id
      assert_response :success
      json_response = JSON.parse(response.body)
      json_response['job_id'].should == cpcs.job_id
      json_response['jobStatus'].should == 'Processing'
      json_response['completed_steps'][0].should == 'Prepared courses list'
      json_response['completed_steps'][1].should == 'Identified department sub-account'
    end
  end

  describe "#options_from_params" do
    it "returns feed option parameters" do
      subject.params['controller'] = 'canvas_course_provision'
      subject.params['action'] = 'get_feed'
      subject.params['admin_acting_as'] = admin_acting_as
      subject.params['admin_by_ccns'] = admin_by_ccns
      subject.params['canvas_course_id'] = canvas_course_id
      subject.params['admin_term_slug'] = admin_term_slug
      result = subject.options_from_params
      expect(result.keys.count).to eq 4
      expect(result).to be_an_instance_of Hash
      expect(result[:admin_acting_as]).to eq admin_acting_as
      expect(result[:admin_by_ccns].count).to eq 2
      expect(result[:admin_by_ccns][0]).to eq admin_by_ccns[0]
      expect(result[:admin_term_slug]).to eq admin_term_slug
      expect(result[:canvas_course_id]).to eq canvas_course_id.to_i
    end

    it 'returns canvas_course_id session variable if LTI embedded' do
      subject.session['canvas_course_id'] = canvas_course_id
      subject.params['canvas_course_id'] = 'embedded'
      subject.params['controller'] = 'canvas_course_provision'
      subject.params['action'] = 'get_feed'
      subject.params['admin_acting_as'] = admin_acting_as
      result = subject.options_from_params
      expect(result.keys.count).to eq 2
      expect(result).to be_an_instance_of Hash
      expect(result[:admin_acting_as]).to eq admin_acting_as
      expect(result[:canvas_course_id]).to eq canvas_course_id.to_i
    end
  end
end
