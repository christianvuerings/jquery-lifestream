require "spec_helper"

describe Proxy do
  let(:user_id) { rand(99999).to_s }

  describe 'getting a fake feed' do
    before { Rails.cache.should_receive(:write) }
    subject { Proxy.new({:user_id => user_id, :fake => true}).get_sites }
    its(:size) { should be > 0 }
    it 'contains Research groups' do
      subject.each do |group|
        expect(group[:id]).to be_present
        expect(group[:name]).to be_present
        expect(group[:site_url]).to be_present
        expect(group[:emitter]).to eq("researchhub")
      end
    end
  end

  describe 'getting a feed for anonymous user' do
    subject { Proxy.new({:user_id => user_id}).get_sites }
    its(:size) { should eq 0 }
  end
end
