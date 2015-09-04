require 'spec_helper'

describe CampusSolutions::SirConfig do

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:sirConfig]).to be
      expect(subject[:feed][:sirConfig][:sirForms][0][:descrProgram]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::SirConfig.new(fake: true) }
    subject { proxy.get }
    it_should_behave_like 'a proxy that gets data'
    it 'gets specific mock data' do
      expect(subject[:feed][:sirConfig][:sirForms][0][:descrProgram]).to eq 'Grad Div Academic Prg'
      expect(subject[:feed][:sirConfig][:sirForms][0][:chklstItemCd]).to eq 'AGS001'
    end
  end

  context 'real proxy', testext: true do
    let(:proxy) { CampusSolutions::SirConfig.new(fake: false) }
    it_should_behave_like 'a proxy that gets data'
  end

end
