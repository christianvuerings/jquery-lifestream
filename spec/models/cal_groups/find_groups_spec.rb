describe CalGroups::FindGroups do
  let(:stem_name) { 'edu:berkeley:app:bcourses' }
  let(:group_name) { "site-#{random_id}" }
  let(:qualified_group_name) { [stem_name, group_name].join(':') }

  let(:proxy) { CalGroups::FindGroups.new(stem_name: stem_name, fake: fake) }

  let(:find_group) { proxy.find_group_by_name qualified_group_name }
  let(:name_available_response) { proxy.name_available?(group_name)[:response]  }

  after(:each) { WebMock.reset! }

  shared_examples 'group found' do
    it 'returns data for a single group' do
      expect(find_group).to have(1).item
      %w(displayExtension displayName extension idIndex name typeOfGroup uuid).each do |key|
        expect(find_group.first[key]).to be_present
      end
    end

    it 'reports group name as unavailable' do
      expect(name_available_response).to eq false
    end
  end

  shared_examples 'group not found' do
    it 'finds nothing' do
      expect(find_group).to be_empty
    end

    it 'reports group name as available' do
      expect(name_available_response).to eq true
    end
  end

  context 'using fake data feed' do
    let(:fake) { true }

    context 'default fake group' do
      include_examples 'group found'
    end

    context 'when group does not exist' do
      before do
        proxy.override_json do |json|
          json['WsFindGroupsResults'].delete 'groupResults'
        end
      end
      include_examples 'group not found'
    end

    context 'when response metadata reports failure' do
      before do
        proxy.override_json do |json|
          json['WsFindGroupsResults']['resultMetadata']['success'] = 'F'
        end
      end
      it 'should return an error' do
        expect(name_available_response[:statusCode]).to eq 503
      end
    end
  end

  context 'using real data feed', testext: true do
    let(:fake) { false }

    context 'a known test group' do
      let(:group_name) { 'testgroup' }
      include_examples 'group found'
    end

    context 'a nonexistent group' do
      let(:group_name) { 'pleasedonotcreateagroupwiththisname' }
      include_examples 'group not found'
    end

    it_should_behave_like 'a proxy logging errors' do
      subject { name_available_response }
    end
  end

end
