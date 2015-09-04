require 'spec_helper'

describe CampusSolutions::ChecklistController do
  context 'direct checklist feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:user) { random_id }
      let(:feed_key) { 'checkListItems' }
      it_behaves_like 'a successful feed'
    end
  end
end
