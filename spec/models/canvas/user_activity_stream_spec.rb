describe Canvas::UserActivityStream do

  let(:uid) { Settings.canvas_proxy.test_user_id }
  subject { Canvas::UserActivityStream.new(user_id: uid) }
  let(:response) { subject.user_activity }

  before do
    User::Oauth2Data.new_or_update(uid, Canvas::Proxy::APP_ID, Settings.canvas_proxy.test_user_access_token)
  end

  after { WebMock.reset! }

  subject { Canvas::UserActivityStream.new(user_id: uid) }

  it 'should get real user activity feed using the Tammi account', :testext => true do
    user_activity = response[:body]
    expect(user_activity).to be_a Array
  end

  context 'on request failure' do
    let(:failing_request) { {method: :get} }
    it_should_behave_like 'an unpaged Canvas proxy handling request failure'
  end
end
