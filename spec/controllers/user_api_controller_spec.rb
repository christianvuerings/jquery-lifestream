require 'spec_helper'

describe UserApiController do
  let (:user_id) { random_id }
  before do
    session[:user_id] = user_id
    allow(CampusOracle::UserAttributes).to receive(:new).with(user_id: user_id).and_return(double(get_feed: {
      'person_name' => 'Joe Test',
      :roles => {
        :student => true,
        :faculty => false,
        :staff => false
      }
    }))
    allow(Settings.features).to receive(:reauthentication).and_return(false)
  end

  context 'when not logged in' do
    let(:user_id) { nil }
    it 'should not have a logged-in status' do
      get :mystatus
      assert_response :success
      json_response = JSON.parse(response.body)
      json_response['isLoggedIn'].should == false
      json_response['uid'].should be_nil
      json_response['features'].should_not be_nil
    end
  end

  context 'when a known real user' do
    let(:user_id) { '238382' }
    it 'should show status' do
      get :mystatus
      json_response = JSON.parse(response.body)
      expect(json_response['isLoggedIn']).to be_true
      expect(json_response['uid']).to eq user_id
      expect(json_response['preferred_name']).to be_present
      expect(json_response['features']).to be_present
      visit = User::Visit.where(:uid => session[:user_id])[0]
      expect(visit.last_visit_at).to be_present
    end
  end

  context 'when a new user' do
    it 'should record the first login' do
      get :mystatus
      json_response = JSON.parse(response.body)
      expect(json_response['firstLoginAt']).to be_nil
      get :record_first_login
      expect(response.status).to eq 204
      get :mystatus
      json_response = JSON.parse(response.body)
      expect(json_response['firstLoginAt']).to be_present
    end
  end

  describe '#acting_as_uid' do
    subject do
      get :mystatus
      JSON.parse(response.body)['actingAsUid']
    end
    context 'when normally authenticated' do
      it { should be false }
    end
    context 'when viewing as' do
      let(:original_user_id) { random_id }
      before { session[:original_user_id] = original_user_id }
      it { should eq original_user_id }
    end
    context 'when authenticated by LTI' do
      before { session[:lti_authenticated_only] = true }
      it { should eq 'Authenticated through LTI' }
    end
  end

  describe 'superuser status' do
    before do
      session[:original_user_id] = original_user_id
      allow(User::Auth).to receive(:get) do |uid|
        case uid
          when user_id
            double(is_superuser?: true, is_viewer?: false, active?: true)
          when original_user_id
            double(is_superuser?: false, is_viewer?: true, active?: true)
        end
      end
    end
    context 'getting status as a superuser' do
      subject do
        get :mystatus
        JSON.parse(response.body)['isSuperuser']
      end
      context 'when normally authenticated' do
        let(:original_user_id) { nil }
        it { should be_true }
      end
      context 'when viewing as' do
        let(:original_user_id) { random_id }
        it { should be_false }
      end
      context 'when authenticated by LTI' do
        let(:original_user_id) { nil }
        before { session[:lti_authenticated_only] = true }
        it { should be_false }
      end
    end

    context 'altering another users data as a superuser should not be possible' do

      context 'recording first login' do
        subject do
          before { User::Api.should_not_receive(:from_session) }
          get :record_first_login
          context 'when viewing as' do
            let(:original_user_id) { random_id }
            expect(response.status).to eq 204
          end
          context 'when authenticated by LTI' do
            let(:original_user_id) { nil }
            before { session[:lti_authenticated_only] = true }
            it { should eq 403 }
          end
        end
      end

      context 'opting out of calcentral entirely' do
        before { User::Api.should_not_receive(:delete) }
        subject do
          post :delete
          response.status
        end
        context 'when viewing as' do
          let(:original_user_id) { random_id }
          it { should eq 403 }
        end
        context 'when authenticated by LTI' do
          let(:original_user_id) { nil }
          before { session[:lti_authenticated_only] = true }
          it { should eq 403 }
        end
      end

      context 'opting into the calendar integration' do
        before { Calendar::User.should_not_receive(:first_or_create) }
        subject do
          post :calendar_opt_in
          response.status
        end
        context 'when viewing as' do
          let(:original_user_id) { random_id }
          it { should eq 403 }
        end
        context 'when authenticated by LTI' do
          let(:original_user_id) { nil }
          before { session[:lti_authenticated_only] = true }
          it { should eq 403 }
        end
      end
      context 'opting out of the calendar integration' do
        before { Calendar::User.should_not_receive(:delete_all) }
        subject do
          post :calendar_opt_out
          response.status
        end
        context 'when viewing as' do
          let(:original_user_id) { random_id }
          it { should eq 403 }
        end
        context 'when authenticated by LTI' do
          let(:original_user_id) { nil }
          before { session[:lti_authenticated_only] = true }
          it { should eq 403 }
        end
      end
    end
  end

  describe '#calendar_opt_in' do
    it 'should handle an opt-in' do
      Calendar::User.should_receive(:first_or_create)
      post :calendar_opt_in
      expect(response.status).to eq 204
    end
  end

  describe '#calendar_opt_out' do
    it 'should handle an opt-out' do
      Calendar::User.should_receive(:delete_all)
      post :calendar_opt_out
      expect(response.status).to eq 204
    end
  end

end
