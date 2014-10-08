require "spec_helper"

describe UserSpecificModel do

  describe '#from_session' do
    let(:fake_session) {{
      user_id: random_id,
      original_user_id: random_id,
      lti_authenticated_only: true
    }}
    it 'instantiates using session variables' do
      expect(UserSpecificModel).to receive(:new).with(fake_session[:user_id], {
        original_user_id: fake_session[:original_user_id],
        lti_authenticated_only: fake_session[:lti_authenticated_only]
      })
      UserSpecificModel.from_session(fake_session)
    end
  end

  describe '#directly_authenticated?' do
    subject {UserSpecificModel.from_session(fake_session).directly_authenticated?}
    context 'when normally authenticated' do
      let(:fake_session) {{
        user_id: random_id
      }}
      it {should be_truthy}
    end
    context 'when viewing as' do
      let(:fake_session) {{
        user_id: random_id,
        original_user_id: random_id
      }}
      it {should be_falsey}
    end
    context 'when only authenticated from an external app' do
      let(:fake_session) {{
        user_id: random_id,
        lti_authenticated_only: true
      }}
      it {should be_falsey}
    end
  end

end
