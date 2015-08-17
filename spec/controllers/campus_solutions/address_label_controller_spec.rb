require 'spec_helper'

describe AddressLabelController do
  context 'address label feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:user) { random_id }
      let(:feed_key) { 'addressFormat' }
      it_behaves_like 'a successful feed'
    end
  end
end
