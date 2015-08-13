require 'spec_helper'

describe FinancialAidDataController do

  context 'financial data feed' do
    let(:feed) { :financial_aid_data }
    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:user) { random_id }
      let(:feed_key) { 'coa' }
      it_behaves_like 'a successful feed'
      it 'has some field mapping info' do
        session['user_id'] = user
        get feed, {:aid_year => '2016', :format => 'json'}
        json = JSON.parse(response.body)
        expect(json['feed']['coa']['title']).to eq 'Estimated Cost of Attendance'
      end
    end
  end

end
