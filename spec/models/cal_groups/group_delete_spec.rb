include CalGroupsHelperModule

describe CalGroups::GroupDelete do
  let(:stem_name) { 'edu:berkeley:app:bcourses' }
  let(:group_name) { 'testgroup' }
  let(:proxy) { described_class.new(stem_name: stem_name, group_name: group_name, fake: fake) }
  let(:result) { proxy.delete[:response] }

  after(:each) { WebMock.reset! }

  context 'fake data feed' do
    let(:fake) { true }

    it 'affirms deletion and returns group data' do
      expect(result[:deleted]).to eq true
      expect_valid_group_data(result[:group])
    end

    context 'nonexistent group' do
      before do
        proxy.override_json do |json|
          json['WsGroupDeleteLiteResult']['resultMetadata']['resultCode'] = 'SUCCESS_GROUP_NOT_FOUND'
        end
      end

      it 'denies deletion and returns group data' do
        expect(result[:deleted]).to eq false
        expect_valid_group_data(result[:group])
      end
    end

    context 'on unspecified failure' do
      before do
        proxy.override_json do |json|
          json['WsGroupDeleteLiteResult']['resultMetadata']['success'] = 'F'
        end
      end
      it 'returns an error' do
        expect(result[:statusCode]).to eq 503
      end
    end
  end

  context 'real data feed' do
    let(:fake) { false }
    subject { result }

    it_behaves_like 'a proxy logging errors'
    it_behaves_like 'a polite HTTP client'
  end
end
