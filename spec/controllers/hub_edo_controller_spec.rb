describe HubEdoController do
  let(:user_id) { '61889' }
  context 'person feed' do
    let(:feed) { :person }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:feed_key) { 'student' }
      it_behaves_like 'a successful feed'
    end
  end
  context 'student feed' do
    let(:feed) { :student }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:feed_key) { 'student' }
      it_behaves_like 'a successful feed'
    end
  end
  context 'work exp feed' do
    let(:feed) { :work_experience }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:feed_key) { 'workExperiences' }
      it_behaves_like 'a successful feed'
    end
  end
end

