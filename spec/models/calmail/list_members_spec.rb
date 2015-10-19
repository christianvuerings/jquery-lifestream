describe Calmail::ListMembers do
  subject { described_class.new(fake: true) }
  let(:list_name) { "site-#{random_id}" }

  describe '#list_members' do
    let(:result) { subject.list_members(list_name)[:response] }
    context 'populated mailing list' do
      it 'returns email addresses' do
        addresses = result[:addresses]
        expect(addresses).to be_present
        expect(addresses).to include('raydavis@berkeley.edu')
      end
    end
  end

  it_behaves_like 'a polite HTTP client' do
    subject { described_class.new(fake: true).list_members(list_name) }
  end
end
