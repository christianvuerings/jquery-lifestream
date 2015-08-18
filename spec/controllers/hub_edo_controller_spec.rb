require 'spec_helper'

describe HubEdoController do
  context 'person feed' do
    let(:feed) { :person }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:user) { random_id }
      let(:feed_key) { 'person' }
      it_behaves_like 'a successful feed'
    end
  end
end

