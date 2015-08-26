require 'spec_helper'

describe CampusSolutions::CurrencyCodeController do
  context 'currency code feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:user) { random_id }
      let(:feed_key) { 'currencyCodes' }
      it_behaves_like 'a successful feed'
    end
  end
end

