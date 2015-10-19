describe PhotoController do
  let(:user_id) { random_id }

  context 'when serving a users photo' do
    context 'when user is logged in' do
        before do
          session['user_id'] = random_id
        end
      context 'when user has photo' do
        before do
          test_photo_object = {'photo' => 'photo_binary_content'}
          allow(CampusOracle::Queries).to receive(:get_photo).and_return(test_photo_object)
        end
        it 'renders users raw image' do
          get :my_photo
          expect(response.status).to eq 200
          expect(response.body).to eq 'photo_binary_content'
        end
      end
      context 'when user has no photo' do
        before do
          allow(CampusOracle::Queries).to receive(:get_photo).and_return(nil)
        end
        it 'renders users raw image' do
          get :my_photo
          expect(response.status).to eq 200
          expect(response.body).to eq ' '
        end
      end
    end

  end

end
