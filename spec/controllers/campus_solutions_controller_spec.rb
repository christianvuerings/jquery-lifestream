require "spec_helper"

describe CampusSolutionsController do

  before(:each) do
    @user_id = rand(99999).to_s
  end

  shared_examples 'an empty feed' do
    it 'has no content' do
      get feed
      json = JSON.parse(response.body)
      expect(json).to eq({})
    end
  end

  shared_examples 'a successful feed' do
    it 'has some data' do
      session['user_id'] = user
      get feed
      json = JSON.parse(response.body)
      expect(json['statusCode']).to eq 200
      expect(json['feed'][feed_key]).to be
    end
  end

  context 'country feed' do
    let(:feed) { :country }
    context 'non-authenticated user' do
      it_behaves_like 'an empty feed'
    end

    context 'authenticated user' do
      let(:user) { @user_id }
      let(:feed_key) { 'countries' }
      it_behaves_like 'a successful feed'
    end
  end

  context 'state feed' do
    let(:feed) { :state }
    context 'non-authenticated user' do
      it_behaves_like 'an empty feed'
    end

    context 'authenticated user' do
      let(:user) { @user_id }
      let(:feed_key) { 'states' }
      it_behaves_like 'a successful feed'
    end
  end

end
