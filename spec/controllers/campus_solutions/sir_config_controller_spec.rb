require 'spec_helper'

describe CampusSolutions::SirConfigController do
  context 'sir config feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:user) { random_id }
      let(:feed_key) { 'sirConfig' }
      it_behaves_like 'a successful feed'
    end
  end
end
