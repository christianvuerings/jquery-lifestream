require "spec_helper"

describe SakaiMergedUserSites do
  let(:uid) {'300939'}
  subject {SakaiMergedUserSites.new(user_id: uid).get_feed}

  context 'when potentially testing against live data' do
    its([:courses]) {should_not be_nil}
    its([:groups]) {should_not be_nil}
    it 'contains properly formatted course items' do
      subject[:courses].each do |site|
        expect(site[:id]).to be_present
        expect(site[:site_url]).to be_present
        expect(site[:name]).to be_present
        expect(site[:emitter]).to eq SakaiProxy::APP_ID
        expect(site[:term_yr]).to be_present
        expect(site[:term_cd]).to be_present
      end
    end
    it 'contains properly formatted group items' do
      subject[:groups].each do |site|
        expect(site[:id]).to be_present
        expect(site[:site_url]).to be_present
        expect(site[:name]).to be_present
        expect(site[:emitter]).to eq SakaiProxy::APP_ID
        expect(site[:term_yr]).to be_nil
        expect(site[:term_cd]).to be_nil
      end
    end
  end

  context 'when running against test data', :if => SakaiData.test_data? do
    it 'includes linked sections and group memberships' do
      site = subject[:courses].select {|site| site[:id] == '29fc31ae-ff14-419f-a132-5576cae2474e'}.first
      expect(site[:groups].length).to eq(1)
      expect(site[:sections]).to eq([{ccn: '7366'}, {ccn: '7372'}])
    end
    it 'excludes unpublished sites' do
      expect(subject[:courses].index {|site| site[:id] == 'cc56df9a-3ae1-4362-a4a0-6c5133ec8750'}).to be_nil
    end
    it 'excludes hidden sites' do
      expect(subject[:groups].index {|site| site[:id] == '47449ea5-6826-4826-807d-af49a5d222fb'}).to be_nil
    end
  end

end
