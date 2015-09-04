require 'spec_helper'

describe CampusSolutions::HigherOneUrlController do

  context 'higher one url feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:user) { random_id }
      let(:feed_key) { 'root' }
      it_behaves_like 'a successful feed'
      it 'has some field mapping info' do
        session['user_id'] = user
        get feed
        json = JSON.parse(response.body)
        expect(json['feed']['root']['higherOneUrl']['url'].strip).to eq 'https://commerce.cashnet.com/UCBpaytest?eusername=8062064084e9a8dff7a181266a3ed11e28b80eb30ab4fd84b9bc4de92394d884'
      end
    end
  end

end
