include CalGroupsHelperModule

describe CalGroups::MemberDelete do
  let(:stem_name) { 'edu:berkeley:app:bcourses' }
  let(:group_name) { "site-#{random_id}" }
  let(:member_id) { random_id }
  let(:proxy) { described_class.new(stem_name: stem_name, group_name: group_name, member_id: member_id, fake: fake) }
  let(:result) { proxy.delete[:response] }

  after(:each) { WebMock.reset! }

  context 'fake data feed' do
    let(:fake) { true }

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

    context 'when member is successfully deleted' do
      it 'affirms deletion' do
        expect(result[:deleted]).to eq true
      end
      include_examples 'verbose response'
    end

    context 'when member is not in group or does not exist' do
      before do
        proxy.override_json do |json|
          json['WsDeleteMemberLiteResult']['resultMetadata']['resultCode'] = 'SUCCESS_WASNT_IMMEDIATE'
        end
      end
      it 'denies deletion' do
        expect(result[:deleted]).to eq false
      end
      include_examples 'verbose response'
    end

    context 'when group does not exist' do
      before do
        proxy.set_response({
          status: 404,
          body: '{"WsDeleteMemberLiteResult":{"resultMetadata":{"resultCode":"GROUP_NOT_FOUND","success":"F"}}}'
        })
      end
      include_examples 'error response'
    end

    context 'on unspecified failure' do
      before do
        proxy.override_json do |json|
          json['WsDeleteMemberLiteResult']['resultMetadata']['success'] = 'F'
        end
      end
      include_examples 'error response'
    end
  end

  context 'real data feed' do
    let(:fake) { false }
    subject {result}

    it_behaves_like 'a proxy logging errors'
    it_behaves_like 'a polite HTTP client'
  end
end
