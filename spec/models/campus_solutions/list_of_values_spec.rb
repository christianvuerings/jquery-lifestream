require 'spec_helper'

describe CampusSolutions::ListOfValues do

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:values][0][:code]).to be
      expect(subject[:feed][:values][0][:desc]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::ListOfValues.new(
      fake: true,
      params: {
        fieldName: 'COUNTRY_NM_FORMAT',
        recordName: 'NAME_FORMAT_TBL'
      }) }
    it_should_behave_like 'a proxy that gets data'
  end

  context 'real proxy', testext: true do
    let(:proxy) { CampusSolutions::ListOfValues.new(
      fake: false,
      params: {
        fieldName: 'COUNTRY_NM_FORMAT',
        recordName: 'NAME_FORMAT_TBL'
      }) }
    it_should_behave_like 'a proxy that gets data'
  end

end
