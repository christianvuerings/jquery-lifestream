require 'spec_helper'

describe PhotoController do
  let(:user_id) { random_id }

  context "when serving a users photo" do
    context "when user is logged in" do
        before do
          session['user_id'] = random_id
        end
      context "when user has photo" do
        before do
          test_photo_object = {'photo' => 'photo_binary_content'}
          CampusOracle::Queries.stub(:get_photo).and_return(test_photo_object)
        end
        it "renders users raw image" do
          expect(controller).to receive(:send_data).with('photo_binary_content', type: 'image/jpeg', disposition: 'inline'){
            controller.render nothing: true
          }
          get :my_photo
        end
      end
      context "when user has no photo" do
        before do
          test_photo_object = nil
          CampusOracle::Queries.stub(:get_photo).and_return(test_photo_object)
        end
        it "renders users raw image" do
          allow(controller).to receive(:send_data).with(nil, type: 'image/jpeg', disposition: 'inline').and_return(true)
          get :my_photo
        end
      end
    end

  end

end
