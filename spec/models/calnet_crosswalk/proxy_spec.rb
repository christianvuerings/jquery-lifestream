require 'spec_helper'

describe CalnetCrosswalk::Proxy do

  shared_examples 'a proxy that returns data' do
    it 'returns data with the expected structure' do
      expect(feed['Person']).to be
      expect(feed['Person']['identifiers'][0]['identifierValue']).to be
    end
  end

  shared_context 'looking up ids' do
    context 'looking up cs id' do
      subject { proxy.lookup_campus_solutions_id }
      it 'should return the CS ID' do
        expect(subject).to eq '11667051'
      end
    end

    context 'looking up student id' do
      subject { proxy.lookup_student_id }
      it 'should return the Student ID' do
        expect(subject).to eq '11667051'
      end
    end
  end

  context 'mock proxy' do
    let(:proxy) { CalnetCrosswalk::Proxy.new(user_id: '61889', fake: true) }
    let(:feed) { proxy.get[:feed] }
    it_behaves_like 'a proxy that returns data'
    it 'can be overridden to return errors' do
      proxy.set_response(status: 506, body: '')
      response = proxy.get
      expect(response[:errored]).to eq true
    end
    include_context 'looking up ids'
  end

  context 'real proxy', testext: true do
    let(:proxy) { CalnetCrosswalk::Proxy.new(user_id: '61889', fake: false) }
    let(:feed) { proxy.get[:feed] }
    it_behaves_like 'a proxy that returns data'
    include_context 'looking up ids'
  end

end
