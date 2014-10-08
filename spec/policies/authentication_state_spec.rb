require "spec_helper"

describe AuthenticationState do

  describe '#directly_authenticated?' do
    subject {AuthenticationState.new(fake_session).directly_authenticated?}
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
    context 'when not logged in' do
      let(:fake_session) {{
      }}
      it {should be_falsey}
    end
  end

  describe '#real_user_id' do
    subject {AuthenticationState.new(fake_session).real_user_id}
    context 'when normally authenticated' do
      let(:fake_session) {{
        user_id: random_id
      }}
      it {should eq fake_session[:user_id]}
    end
    context 'when viewing as' do
      let(:fake_session) {{
        user_id: random_id,
        original_user_id: random_id
      }}
      it {should eq fake_session[:original_user_id]}
    end
    context 'when only authenticated from an external app' do
      let(:fake_session) {{
        user_id: random_id,
        lti_authenticated_only: true
      }}
      it {should eq AuthenticationState::LTI_AUTHENTICATED_ONLY}
    end
    context 'when not logged in' do
      let(:fake_session) {{
      }}
      it {should be_falsey}
    end
  end

  describe '#viewing_as?' do
    subject {AuthenticationState.new(fake_session).viewing_as?}
    context 'when normally authenticated' do
      let(:fake_session) {{
        user_id: random_id
      }}
      it {should be_falsey}
    end
    context 'when viewing as' do
      let(:fake_session) {{
        user_id: random_id,
        original_user_id: random_id
      }}
      it {should be_truthy}
    end
    context 'when only authenticated from an external app' do
      let(:fake_session) {{
        user_id: random_id,
        lti_authenticated_only: true
      }}
      it {should be_falsey}
    end
    context 'when not logged in' do
      let(:fake_session) {{
      }}
      it {should be_falsey}
    end
  end

end
