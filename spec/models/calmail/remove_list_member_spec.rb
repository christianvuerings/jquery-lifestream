describe Calmail::RemoveListMember do
  subject { described_class.new(fake: true) }

  describe '#remove_member' do
    let(:list_name) { "site-#{random_id}" }
    let(:email_address) { "th_#{random_id}@example.com" }
    let(:result) { subject.remove_member(list_name, email_address)[:response] }
    context 'address is in list' do
      it 'succeeds' do
        expect(result).to eq({email_address: email_address, removed: true})
      end
    end
    context 'specified address is not in list' do
      before do
        subject.set_response(subject.mock_response_not_a_member)
      end
      it 'fails gracefully' do
        expect(result).to eq({email_address: email_address, removed: false})
      end
    end
    it_behaves_like 'a polite HTTP client' do
      subject { described_class.new(fake: true).remove_member(list_name, email_address) }
    end
  end

end
