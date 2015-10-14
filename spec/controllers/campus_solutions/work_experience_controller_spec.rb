require 'spec_helper'

describe CampusSolutions::WorkExperienceController do

  let(:user_id) { '12351' }

  context 'updating work experience' do
    it 'should not let an unauthenticated user post' do
      post :post, {format: 'json', uid: '100'}
      expect(response.status).to eq 401
    end

    context 'authenticated user' do
      before do
        session['user_id'] = user_id
        User::Auth.stub(:where).and_return([User::Auth.new(uid: user_id, is_superuser: false, active: true)])
      end
      it 'should let an authenticated user post' do
        post :post,
             {
               bogus_field: 'abc',
               extOrganizationId: '9000000008',
               isRetired: 'N',
               workExpAddrType: 'ADDR',
               country: 'USA',
               addressType: 'HOME',
               city: 'ventura',
               state: 'CA',
               phoneType: '',
               phone: '1234',
               startDt: '2012-08-11',
               endDt: '2015-08-11',
               retirementDt: '',
               titleLong: 'Test Title',
               employFrac: '10',
               hoursPerWeek: '4',
               endingPayRate: '10000',
               currencyCd: 'USD',
               payFrequency: 'M'
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
