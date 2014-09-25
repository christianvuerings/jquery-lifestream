require "spec_helper"

describe ActAsController do

  def it_succeeds
    post :start, uid: target_uid
    expect(response).to be_success
    expect(session[:user_id]).to eq target_uid
    expect(session[:original_user_id]).to eq real_user_id
  end
  def it_fails
    post :start, uid: target_uid
    expect(response).to_not be_success
    expect(session[:user_id]).to_not eq target_uid
    expect(session[:original_user_id]).to be_nil
  end

  describe '#start' do
    let(:target_uid) {'978966'}
    let(:real_user_id) {'1021845'}
    let(:real_active) {true}
    before do
      allow(Settings.features).to receive(:reauthentication).and_return(false)
      allow(User::Auth).to receive(:get).with(real_user_id).and_return(double(
        is_superuser?: real_superuser,
        is_viewer?: real_viewer,
        active?: real_active
      ))
    end
    shared_examples 'successful view-as' do
      it 'works the first time' do
        session[:user_id] = real_user_id
        it_succeeds
      end
      it 'switches targets' do
        session[:user_id] = '211159'
        session[:original_user_id] = real_user_id
        it_succeeds
      end
    end
    context 'superuser' do
      let(:real_superuser) {true}
      let(:real_viewer) {false}
      it_behaves_like 'successful view-as'
    end
    context 'viewer' do
      let(:real_superuser) {false}
      let(:real_viewer) {true}
      it_behaves_like 'successful view-as'
    end
    context 'possible Canvas masquerader' do
      let(:real_superuser) {true}
      let(:real_viewer) {false}
      before do
        # Override the previous stub.
        allow(User::Auth).to receive(:get).with(nil).and_call_original
      end
      it 'is denied' do
        session[:user_id] = real_user_id
        session[:lti_authenticated_only] = true
        it_fails
      end
    end
    context 'normal user' do
      let(:real_superuser) {false}
      let(:real_viewer) {false}
      it 'is denied' do
        session[:user_id] = real_user_id
        it_fails
      end
    end
  end

end
