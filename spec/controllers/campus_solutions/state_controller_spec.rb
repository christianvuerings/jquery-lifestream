require 'spec_helper'

describe StateController do
  context 'state feed' do
    let(:feed) { :state }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:user) { random_id }
      let(:feed_key) { 'states' }
      it_behaves_like 'a successful feed'
    end
  end
end
