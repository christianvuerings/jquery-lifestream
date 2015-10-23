describe MyGroups::Callink do
  let(:user_id) { rand(99999).to_s }

  describe '#fetch' do
    let!(:fake_cal_link_proxy) do
      CalLink::Memberships.new({fake: true})
    end
    before {Settings.cal_link_proxy.stub(:fake).and_return(true)}
    before {CalLink::Memberships.stub(:new).with(user_id: user_id).and_return(fake_cal_link_proxy)}
    subject {MyGroups::Callink.new(user_id).fetch}
    its(:size) {should be > 0}
    it 'contains CalLink groups' do
      subject.each do |group|
        expect(group[:id]).to be_present
        expect(group[:name]).to be_present
        expect(group[:site_url]).to be_present
        expect(group[:emitter]).to eq(CalLink::Proxy::APP_ID)
      end
    end
    it 'filters out blacklisted groups' do
      bad_groups = %w(91370 59672 45984 46063 91891 93520 67825)
      expect(subject.select {|group| bad_groups.include?(group[:id])}).to be_empty
    end
  end

end
