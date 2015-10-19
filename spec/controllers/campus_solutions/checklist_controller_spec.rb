describe CampusSolutions::ChecklistController do

  let(:user_id) { '12345' }

  context 'direct checklist feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:feed_key) { 'checkListItems' }
      it_behaves_like 'a successful feed'
    end
  end
end
