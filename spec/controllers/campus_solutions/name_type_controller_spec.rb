require 'spec_helper'

describe CampusSolutions::NameTypeController do
  context 'name type feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:user_id) { random_id }
      let(:feed_key) { 'nameTypes' }
      it_behaves_like 'a successful feed'
    end
  end
end

