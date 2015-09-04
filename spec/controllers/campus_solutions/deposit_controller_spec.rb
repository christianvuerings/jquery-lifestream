require 'spec_helper'

describe CampusSolutions::DepositController do

  context 'deposit feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:user) { random_id }
      let(:feed_key) { 'depositResponse' }
      it_behaves_like 'a successful feed'
      it 'has some field mapping info' do
        session['user_id'] = user
        get feed, {:adm_appl_nbr => '00000087', :format => 'json'}
        json = JSON.parse(response.body)
        expect(json['feed']['depositResponse']['deposit']['dueDt']).to eq '2015-09-01'
      end
    end
  end

end
