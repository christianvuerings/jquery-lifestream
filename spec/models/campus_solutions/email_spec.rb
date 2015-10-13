describe CampusSolutions::Email do

  let(:user_id) { '12345' }

  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::Email.new(fake: true, user_id: user_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        email: 'foo@foo.com'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 3
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:email]).to eq 'foo@foo.com'
        expect(subject[:type]).to eq ''
      end
    end

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        type: 'CAMP',
        email: 'foo@foo.com'
      } }
      subject {
        result = proxy.construct_cs_post(params)
        MultiXml.parse(result)['EMAIL_ADDRESS']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['E_ADDR_TYPE']).to eq 'CAMP'
        expect(subject['EMAIL_ADDR']).to eq 'foo@foo.com'
      end
    end

    context 'performing a post' do
      let(:params) { {
        type: 'CAMP',
        email: 'foo@foo.com',
        isPreferred: 'N'
      } }
      subject {
        proxy.get
      }
      it_should_behave_like 'a simple proxy that returns errors'
      it_behaves_like 'a proxy that properly observes the profile feature flag'
      it_behaves_like 'a proxy that got data successfully'
    end
  end

  context 'with a real external service', testext: true do
    let(:proxy) { CampusSolutions::Email.new(fake: false, user_id: user_id, params: params) }
    subject { proxy.get }

    context 'a successful post' do
      let(:params) { {
        type: 'CAMP',
        email: 'foo@foo.com',
        isPreferred: 'Y'
      } }
      context 'performing a real post' do
        it_behaves_like 'a proxy that got data successfully'
      end
    end

    context 'an invalid post' do
      let(:params) { {
        type: 'CAMP',
        email: '',
        isPreferred: ''
      } }
      context 'performing a real but invalid post' do
        it_should_behave_like 'a simple proxy that returns errors'
        it_should_behave_like 'a proxy that responds to user error gracefully'
      end
    end
  end
end
