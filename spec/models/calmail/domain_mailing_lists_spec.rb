describe Calmail::DomainMailingLists do
  subject { described_class.new(fake: true) }

  describe '#get_list_names' do
    let(:result) { subject.get_list_names[:response] }
    it 'returns an array of mailing list names' do
      mailing_lists = result[:lists]
      expect(mailing_lists.size).to eq 2
      expect(mailing_lists).to include('raytest')
    end
  end

  it_behaves_like 'a polite HTTP client' do
    subject { described_class.new(fake: true).get_list_names }
  end
end
