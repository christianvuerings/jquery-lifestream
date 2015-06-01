require 'spec_helper'

describe CampusSolutions::Address do

  context 'getting the feed' do
    let(:fake_proxy) { CampusSolutions::Address.new(fake: true) }
    let(:feed) { fake_proxy.get[:feed] }

    it 'returns JSON fixture data by default' do
      expect(feed[:addresses]).to be
      expect(feed[:addresses][0][:addressType]).to eq 'ISIR'
      expect(feed[:addresses][0][:addressTypeDescr]).to eq 'FA ISIR Address'
      expect(feed[:fields].keys.length).to eq 10
      expect(feed[:fields][:country]).to be
    end

    it 'can be overridden to return errors' do
      fake_proxy.set_response(status: 506, body: '')
      response = fake_proxy.get
      expect(response[:errored]).to eq true
    end

  end

  context 'post' do
    let(:fake_proxy) { CampusSolutions::Address.new(fake: true) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        country: 'USA'
      } }
      subject { fake_proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 1
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:country]).to be
      end
    end

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        country: 'USA',
        address1: '1 Test Lane',
        bogus: 1,
        invalid: 2
      } }
      subject { fake_proxy.construct_cs_post(params) }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject.keys.length).to eq 2
        expect(subject[:COUNTRY]).to eq 'USA'
        expect(subject[:ADDRESS1]).to eq '1 Test Lane'
      end
    end
  end
end
