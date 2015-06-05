include CalGroupsHelperModule

describe CalGroups::MembersAdd do
  let(:stem_name) { 'edu:berkeley:app:bcourses' }
  let(:group_name) { "site-#{random_id}" }
  let(:member_ids) { 3.times.map { random_id } }
  let(:proxy) { described_class.new(stem_name: stem_name, group_name: group_name, fake: fake) }
  let(:result) { proxy.add(member_ids)[:response] }

  after(:each) { WebMock.reset! }

  context 'fake data feed' do
    let(:fake) { true }

    shared_examples 'error response' do
      it 'reports an error' do
        expect(result[:statusCode]).to eq 503
      end
    end

    it 'includes group data' do
      expect_valid_group_data(result[:group])
    end

    it 'includes member data for members found' do
      result[:members].each do |member|
        expect_valid_member_data(result[:member]) if result[:added]
      end
    end

    it 'returns true for newly added member' do
      member_added = result[:members].find { |m| m[:id] == '211159' }
      expect(member_added[:added]).to eq true
    end

    it 'returns false for member already in group' do
      member_not_added = result[:members].find { |m| m[:id] == '242881' }
      expect(member_not_added[:added]).to eq false
    end

    it 'returns false for member not found' do
      member_not_added = result[:members].find { |m| m[:id] == '9999999' }
      expect(member_not_added[:added]).to eq false
    end

    context 'when group does not exist' do
      before do
        proxy.set_response({
          status: 404,
          body: '{"WsAddMemberResults":{"resultMetadata":{"resultCode":"GROUP_NOT_FOUND","success":"F"}}}'
        })
      end
      include_examples 'error response'
    end

    context 'on unspecified failure' do
      before do
        proxy.override_json do |json|
          json['WsAddMemberResults'].delete 'results'
        end
      end
      include_examples 'error response'
    end
  end

  context 'real data feed' do
    let(:fake) { false }
    subject { result }

    it_behaves_like 'a proxy logging errors'
    it_behaves_like 'a polite HTTP client'
  end
end
