describe Slate::Checklist do

  context 'mock proxy' do
    before do
      allow(Settings.features).to receive(:slate_checklist).and_return(true)
    end

    let(:oski_uid) { '61889' }
    let(:oski_student_id) { 11667051 }
    let(:fake_proxy) { Slate::Checklist.new(user_id: oski_uid, fake: true) }
    let(:feed) { fake_proxy.get[:feed] }

    it 'returns JSON fixture data by default' do
      expect(feed['PERSON_CHKLST']['PERSON_CHKLST_ITEM'][0]['EMPLID']).to eq '3030000004'
      expect(feed['PERSON_CHKLST']['PERSON_CHKLST_ITEM'][0]['NAME']).to eq 'TestLast1, John1 A'
    end
    it 'can be overridden to return errors' do
      fake_proxy.set_response(status: 506, body: '')
      response = fake_proxy.get
      expect(response[:errored]).to eq true
    end
  end

  context 'with the checklist feature disabled' do
    before do
      allow(Settings.features).to receive(:slate_checklist).and_return(false)
    end
    subject { Slate::Checklist.new(user_id: random_id, fake: true).get }
    it 'should return an empty feed' do
       expect(subject).to eq({})
    end
  end
end

