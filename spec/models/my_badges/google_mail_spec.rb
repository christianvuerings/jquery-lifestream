describe "MyBadges::bMail" do

  before(:each) do
    @user_id = rand(999999).to_s
    allow(GoogleApps::Proxy).to receive(:access_granted?).and_return(true)
    allow(GoogleApps::MailList).to receive(:new).and_return(GoogleApps::MailList.new(fake: true))
  end

  subject { MyBadges::GoogleMail.new(@user_id).fetch_counts }

  shared_examples 'an empty result set' do
    it { expect(subject[:count]).to eq 0 }
    it { expect(subject[:items]).to eq [] }
  end

  it 'should find three unread messages' do
    expect(subject[:count]).to eq 3
    expect(subject[:items].count).to eq 3
    subject[:items].each do |item|
      [:editor, :link, :modifiedTime, :summary, :title].each { |key| expect(item[key]).to be_present }
    end
  end

  context 'when XML parsing fails' do
    before { allow(MultiXml).to receive(:parse).and_raise(StandardError) }
    it_should_behave_like 'an empty result set'
  end

  context 'when XML data is unexpected' do
    before { allow(MultiXml).to receive(:parse).and_return(['multi', 'element', 'bogus', 'result']) }
    it_should_behave_like 'an empty result set'
  end

end
