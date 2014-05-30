require 'spec_helper'

describe Financials::MyFinancials do

  let!(:oski_uid) { '61889' }
  let!(:fake_proxy) { Financials::Proxy.new({user_id: oski_uid, fake: true}) }
  before(:each) {
    allow(Financials::Proxy).to receive(:new).and_return(fake_proxy)
  }

  subject { Financials::MyFinancials.new(oski_uid).get_feed }

  shared_examples 'an empty feed' do
    it 'should have just 2 fields' do
      expect(subject.length).to eq 2
    end
  end

  shared_examples 'a feed with the common live-updates fields' do
    it 'should have a lastModified field' do
      expect(subject[:lastModified]).to be
    end
    it 'should have a feedName field' do
      expect(subject[:feedName]).to eq 'Financials::MyFinancials'
    end
  end

  context 'when following a happy path for #get_feed' do
    it 'has a non-nil model response' do
      expect(subject).to be
    end
    it 'has a summary' do
      expect(subject['summary']).to be
    end
    it 'includes the English translation of the current term' do
      expect(subject['currentTerm']).to eq Berkeley::Terms.fetch.current.to_english
    end
    it 'includes an apiVersion field' do
      expect(subject['apiVersion']).to eq '1.0.6'
    end
    it_behaves_like 'a feed with the common live-updates fields'
  end

  context 'when the proxy returns an error condition' do
    before { allow(fake_proxy).to receive(:get).and_return(
                                    {
                                      body: 'an error message',
                                      statusCode: 500
                                    })
    }
    it 'should have an error message text' do
      expect(subject[:body]).to eq 'an error message'
    end
    it 'should have a 500 status code' do
      expect(subject[:statusCode]).to eq 500
    end
    it_behaves_like 'a feed with the common live-updates fields'
  end

  context 'when the proxy returns nil' do
    before { allow(fake_proxy).to receive(:get).and_return(nil) }
    it_behaves_like 'an empty feed'
    it_behaves_like 'a feed with the common live-updates fields'
  end

end
