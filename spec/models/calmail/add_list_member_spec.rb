describe Calmail::AddListMember do
  subject { described_class.new(fake: true) }

  describe '#add_member' do
    let(:list_name) { "site-#{random_id}" }
    let(:email_address) { "th_#{random_id}@example.com" }
    let(:full_name) { "Thurston Howell #{random_id}" }
    let(:result) { subject.add_member(list_name, email_address, full_name)[:response] }
    context 'new address for list' do
      it 'succeeds' do
        expect(result).to eq({email_address: email_address, added: true})
      end
    end
    context 'specified address is already in list' do
      before do
        subject.set_response(subject.mock_response_already_a_member)
      end
      it 'fails gracefully' do
        expect(result).to eq({email_address: email_address, added: false})
      end
    end
    it_behaves_like 'a polite HTTP client' do
      subject { described_class.new(fake: true).add_member(list_name, email_address, full_name) }
    end
  end

end
