require 'spec_helper'

describe CampusSolutions::LanguageCodeController do
  context 'language feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:user_id) { '12345' }
      let(:feed_key) { 'accomplishments' }
      it_behaves_like 'a successful feed'
    end
  end
end

