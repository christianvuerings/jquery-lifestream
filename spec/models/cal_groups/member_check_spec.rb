include CalGroupsHelperModule

describe CalGroups::MemberCheck do
  let(:stem_name) { 'edu:berkeley:app:bcourses' }
  let(:group_name) { "site-#{random_id}" }
  let(:member_id) { random_id }
  let(:proxy) { described_class.new(stem_name: stem_name, group_name: group_name, member_id: member_id, fake: fake) }
  let(:result) { proxy.check[:response] }

  after(:each) { WebMock.reset! }

  shared_examples 'error response' do
    it 'reports an error' do
      expect(result[:statusCode]).to eq 503
    end
  end

  shared_examples 'verbose response' do
    it 'includes member and group data' do
      expect_valid_group_data(result[:group])
      expect_valid_member_data(result[:member])
    end
  end

  context 'using fake data feed' do
    let(:fake) { true }

    context 'when submitted id is a member' do
      it 'affirms membership' do
        expect(result[:isMember]).to eq true
      end
      include_examples 'verbose response'
    end

    context 'when submitted id is not a member' do
      before do
        proxy.override_json do |json|
          json['WsHasMemberLiteResult']['resultMetadata']['resultCode'] = 'IS_NOT_MEMBER'
        end
      end
      it 'denies membership' do
        expect(result[:isMember]).to eq false
      end
      include_examples 'verbose response'
    end

    context 'when member does not exist' do
      before do
        proxy.override_json do |json|
          json['WsHasMemberLiteResult']['resultMetadata']['resultCode'] = 'IS_NOT_MEMBER'
          json['WsHasMemberLiteResult']['resultMetadata']['resultCode2'] = 'SUBJECT_NOT_FOUND'
          json['WsHasMemberLiteResult']['wsSubject'] = {'id' => member_id}
        end
      end
      it 'denies membership' do
        expect(result[:isMember]).to eq false
      end
    end

    context 'when group does not exist' do
      before do
        proxy.set_response({
          status: 404,
          body: '{"WsHasMemberLiteResult":{"resultMetadata":{"resultCode":"GROUP_NOT_FOUND","success":"F"}}}'
        })
      end
      include_examples 'error response'
    end

    context 'on unspecified failure' do
      before do
        proxy.override_json do |json|
          json['WsHasMemberLiteResult']['resultMetadata']['success'] = 'F'
        end
      end
      include_examples 'error response'
    end
  end

  # This testext group is disabled until CLC-5251 is resolved.
  context 'using real data feed', testext: true, ignore: true do
    let(:fake) { false }
    let(:group_name) { 'testgroup' }

    context 'a known member' do
      let(:member_id) { '242881' }
      it 'affirms membership' do
        expect(result[:isMember]).to eq true
      end
      include_examples 'verbose response'
    end

    context 'a known nonmember' do
      let(:member_id) { '1015749' }
      it 'denies membership' do
        expect(result[:isMember]).to eq false
      end
      include_examples 'verbose response'
    end

    it_behaves_like 'a proxy logging errors' do
      subject { result }
    end
  end
end
