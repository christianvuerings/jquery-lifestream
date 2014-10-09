require 'spec_helper'

describe ResearchHub::Proxy do
  let(:user_id) { rand(99999).to_s }

  describe 'getting a fake feed' do
    include_context 'it writes to the cache'
    subject { ResearchHub::Proxy.new({:user_id => user_id, :fake => true}).get_sites }
    its(:size) { should be > 0 }
    it 'contains Research groups' do
      subject.each do |group|
        expect(group[:id]).to be_present
        expect(group[:name]).to be_present
        expect(group[:site_url]).to be_present
        expect(group[:emitter]).to eq('researchhub')
      end
    end
  end

  describe 'getting a feed for anonymous user' do
    subject { ResearchHub::Proxy.new({:user_id => user_id}).get_sites }
    its(:size) { should eq 0 }
  end

  context 'exception on connecting' do
    let(:open_uri_read) {double 'open'}
    before {open_uri_read.stub(:read).and_raise(OpenSSL::SSL::SSLError, 'certificate verify failed')}
    subject { ResearchHub::Proxy.new({:user_id => user_id}) }
    it 'returns an empty array' do
      subject.should_receive(:open).and_return(open_uri_read)
      expect(subject.get_sites).to eq []
    end
  end
end
