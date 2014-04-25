require 'spec_helper'

describe PhotoController do

  let(:unavailable_photo) { File.join(Rails.root, 'app/assets/images', 'photo_unavailable_official_72x96.jpg') }

  context "when serving a users photo" do
    context "when user is logged in" do

      context "when user has photo" do
        before do
          test_photo_object = {:photo => 'photo_binary_content'}
          CampusOracle::Queries.stub(:get_photo).and_return(test_photo_object)
        end
        it "renders users raw image" do
          allow(controller).to receive(:send_data).with('photo_binary_content', type: 'image/jpeg', disposition: 'inline').and_return(true)
          get :my_photo
        end
      end

      context "when user does not have photo" do
        before { CampusOracle::Queries.stub(:get_photo).and_return(nil) }
        it "renders photo unavaiable image" do
          allow(controller).to receive(:send_file).with(unavailable_photo, type: 'image/jpeg', disposition: 'inline').and_return(true)
          get :my_photo
        end
      end

    end

    context "when user is not logged in" do
      before { session[:user_id] = nil }
      it "returns 401 error with no body" do
        get :my_photo
        expect(response.status).to eq 401
        expect(response.body).to eq " "
      end
    end

  end

  
end
