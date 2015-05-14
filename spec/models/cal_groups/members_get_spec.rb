include CalGroupsHelperModule

describe CalGroups::MembersGet do
  let(:stem_name) { 'edu:berkeley:app:bcourses' }
  let(:group_name) { "site-#{random_id}" }

  let(:proxy) { described_class.new(stem_name: stem_name, group_name: group_name, fake: fake) }
  let(:result) { proxy.get[:response] }

  after(:each) { WebMock.reset! }

  shared_examples 'members found' do
    it 'returns data for multiple members' do
      expect(result[:members]).to_not be_empty
      result[:members].each do |member|
        expect(member[:id]).to be_present
      end
      expect_valid_group_data(result[:group])
    end
  end

  shared_examples 'no members found' do
    it 'returns an empty dataset' do
      expect(result[:members]).to be_empty
      expect_valid_group_data(result[:group])
    end
  end

  shared_examples 'group not found' do
    it 'returns an error' do
      expect(result[:statusCode]).to eq 503
    end
  end

  context 'using fake data feed' do
    let(:fake) { true }

    context 'populated mailing list' do
      include_examples 'members found'
    end

    context 'empty mailing list' do
      before do
        proxy.override_json do |json|
          json['WsGetMembersLiteResult'].delete 'wsSubjects'
        end
      end
      include_examples 'no members found'
    end

    context 'a nonexistent group' do
      before do
        proxy.set_response({
          status: 404,
          body: '{"WsGetMembersLiteResult":{"resultMetadata":{"resultCode":"GROUP_NOT_FOUND","success":"F"}}}'
        })
      end
      include_examples 'group not found'
    end

    context 'on unspecified failure' do
      before do
        proxy.override_json do |json|
          json['WsGetMembersLiteResult']['resultMetadata']['success'] = 'F'
        end
      end
      it 'returns an error' do
        expect(result[:statusCode]).to eq 503
      end
    end
  end

  # This testext group is disabled until CLC-5251 is resolved.
  context 'using real data feed', testext: true, ignore: true do
    let(:fake) { false }

    context 'a known test group' do
      let(:group_name) { 'testgroup' }
      include_examples 'members found'
    end

    context 'a nonexistent group' do
      let(:group_name) { 'pleasedonotcreateagroupwiththisname' }
      include_examples 'group not found'
    end
  end

end
