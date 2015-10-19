describe CampusSolutions::FinancialAidDataController do

  let(:user_id) { '12345' }

  context 'financial data feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:feed_key) { 'coa' }
      it_behaves_like 'a successful feed'
      it 'has some field mapping info' do
        session['user_id'] = user_id
        get feed, {:aid_year => '2016', :format => 'json'}
        json = JSON.parse(response.body)
        expect(json['feed']['coa']['title']).to eq 'Estimated Cost of Attendance'
      end
    end
  end

end
