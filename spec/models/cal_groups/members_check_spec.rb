include CalGroupsHelperModule

describe CalGroups::MembersCheck do
  let(:stem_name) { 'edu:berkeley:app:bcourses' }
  let(:group_name) { 'testgroup' }
  let(:member_ids) { ['242881', '1015749', '9999999'] }
  let(:proxy) { described_class.new(stem_name: stem_name, group_name: group_name, fake: fake) }
  let(:result) { proxy.check(member_ids)[:response] }

  after(:each) { WebMock.reset! }


  shared_examples 'error response' do
    it 'reports an error' do
      expect(result[:statusCode]).to eq 503
    end
  end

  shared_examples 'membership expectations' do
    it 'includes group data' do
      expect_valid_group_data(result[:group])
    end

    it 'includes member data for members found' do
      result[:members].each do |member|
        expect_valid_member_data(result[:member]) if result[:isMember]
      end
    end

    it 'returns true for known member' do
      member = result[:members].find { |m| m[:id] == '242881' }
      expect(member[:isMember]).to eq true
    end

    it 'returns false for known nonmember' do
      member = result[:members].find { |m| m[:id] == '1015749' }
      expect(member[:isMember]).to eq false
    end

    it 'returns false for member not found' do
      member = result[:members].find { |m| m[:id] == '9999999' }
      expect(member[:isMember]).to eq false
    end
  end

  context 'fake data feed' do
    let(:fake) { true }

    include_examples 'membership expectations'

    context 'when group does not exist' do
      before do
        proxy.set_response({
          status: 404,
          body: '{"WsHasMemberResults":{"resultMetadata":{"resultCode":"GROUP_NOT_FOUND","success":"F"}}}'
        })
      end
      include_examples 'error response'
    end

    context 'on unspecified failure' do
      before do
        proxy.override_json do |json|
          json['WsHasMemberResults']['resultMetadata']['success'] = 'F'
        end
      end
      include_examples 'error response'
    end
  end

  # This testext group is disabled until CLC-5251 is resolved.
  context 'using real data feed', testext: true, ignore: true do
    let(:fake) { false }

    include_examples 'membership expectations'

    it_behaves_like 'a proxy logging errors' do
      subject { result }
    end
  end
end
