require "spec_helper"

describe MyGroups::Research do
  let(:user_id) { rand(99999).to_s }

  describe '#fetch' do
    before {Settings.research_user_proxy.stub(:fake).and_return(true)}
    subject {MyGroups::Research.new(user_id).fetch}
    its(:size) {should be > 0}
    it 'contains Research groups' do
      subject.each do |group|
        expect(group[:id]).to be_present
        expect(group[:name]).to be_present
        expect(group[:site_url]).to be_present
        expect(group[:emitter]).to eq("researchhub")
      end
    end
  end

end
