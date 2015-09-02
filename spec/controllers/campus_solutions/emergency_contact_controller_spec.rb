require 'spec_helper'

describe CampusSolutions::EmergencyContactController do
  context 'updating emergency contact' do
    it 'should not let an unauthenticated user post' do
      post :post, {format: 'json', uid: '100'}
      expect(response.status).to eq 401
    end

    context 'authenticated user' do
      before do
        session['user_id'] = '1234'
        User::Auth.stub(:where).and_return([User::Auth.new(uid: '1234', is_superuser: false, active: true)])
      end
      it 'should let an authenticated user post' do
        post :post,
             {
               bogus_field: 'abc',
               contactName: 'TEST',
               isSameAddressEmpl: 'N',
               isPrimaryContact: 'Y',
               country: 'USA',
               address1: 'lane7',
               address2: 'peters road',
               address3: 'estella st',
               address4: 'fourth field lane',
               city: 'ventura',
               num1: '1',
               num2: '2',
               houseType: 'AB',
               addrField1: 'L1',
               addrField2: 'L2',
               addrField3: 'L3',
               county: 'Alameda',
               state: 'CA',
               postal: '93001',
               geoCode: '',
               inCityLimit: 'N',
               countryCode: '',
               phone: '805/658-4588',
               relationship: 'SP',
               isSamePhoneEmpl: 'N',
               addressType: 'HOME',
               phoneType: 'CELL',
               extension: '123',
               emailAddr: 'foo@foo.com'
             }
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json['statusCode']).to eq 200
        expect(json['feed']).to be
        expect(json['feed']['status']).to be
      end
    end
  end
  context 'deleting emergency contact' do
    it 'should not let an unauthenticated user delete' do
      delete :delete, {format: 'json', uid: '100'}
      expect(response.status).to eq 401
    end

    context 'authenticated user' do
      before do
        session['user_id'] = '1234'
        User::Auth.stub(:where).and_return([User::Auth.new(uid: '1234', is_superuser: false, active: true)])
      end
      it 'should let an authenticated user delete' do
        post :post,
             {
               bogus_field: 'abc',
               contactName: 'TEST'
             }
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json['statusCode']).to eq 200
        expect(json['feed']).to be
        expect(json['feed']['status']).to be
      end
    end
  end
end
