require 'spec_helper'

describe Financials::Proxy do

  context 'when Oski gets his feed' do
    subject { Financials::Proxy.new({user_id: '61889', student_id: 11667051}).get }
    it 'has some minimal oski data' do
      expect(subject.body).to be
      expect(subject.code).to eq 200
      body = JSON.parse(subject.body)
      expect(body['student']).to be
      expect(body['student']['summary']).to be
      expect(body['student']['summary']['accountBalance']).to be_a(Numeric)
      expect(body['student']['summary']['minimumAmountDue']).to be_a(Numeric)
      expect(Date.parse(body['student']['summary']['minimumAmountDueDate'])).to be_a(Date)
      expect(body['student']['summary']['isOnDPP']).to satisfy { |val|
        val.is_a?(TrueClass) || val.is_a?(FalseClass)
      }
    end
    if Settings.financials_proxy.fake
      it 'should have a specific futureActivity sum' do
        expect(JSON.parse(subject.body)['student']['summary']['futureActivity']).to eq 25.0
      end
    end
  end

end
