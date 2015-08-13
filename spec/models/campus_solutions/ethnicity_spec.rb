require 'spec_helper'

describe CampusSolutions::Ethnicity do

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns JSON fixture data by default' do
      expect(subject[:feed][:ethnictySetup]).to be
      expect(subject[:feed][:ethnictySetup][:answerMapping][:sccHispMap]).to eq 'Hispanic/Latino'
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::Ethnicity.new(fake: true) }
    it_should_behave_like 'a proxy that gets data'
  end

  context 'real proxy' do
    let(:proxy) { CampusSolutions::Ethnicity.new(fake: false) }
    it_should_behave_like 'a proxy that gets data'
  end

end
