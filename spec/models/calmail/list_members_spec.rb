require 'spec_helper'

describe Calmail::ListMembers do
  subject { Calmail::ListMembers.new(fake: true) }
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

end
