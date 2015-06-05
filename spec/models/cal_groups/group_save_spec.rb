include CalGroupsHelperModule

describe CalGroups::GroupSave do
  let(:stem_name) { 'edu:berkeley:app:bcourses' }
  let(:group_name) { "site-#{random_id}" }
  let(:proxy) { described_class.new(stem_name: stem_name, group_name: group_name, fake: fake) }
  let(:result) { proxy.save[:response] }

  after(:each) { WebMock.reset! }

  context 'fake data feed' do
    let(:fake) { true }

    it 'affirms creation and returns data for created group' do
      expect(result[:created]).to eq true
      expect_valid_group_data(result[:group])
    end

    context 'when group already exists' do
      before do
        proxy.set_response({
          status: 500,
          body: proxy.read_file('fixtures', 'json', 'cal_groups_group_save_already_exists.json')
        })
      end
      it 'denies creation and returns minimal data' do
        expect(result[:created]).to eq false
        expect(result[:group][:qualifiedName]).to be_present
        expect(result[:group][:name]).to be_present
      end
    end

    context 'on unspecified failure' do
      before do
        proxy.override_json do |json|
          json['WsGroupSaveLiteResult']['resultMetadata']['success'] = 'F'
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
