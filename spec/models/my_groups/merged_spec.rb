require "spec_helper"

describe MyGroups::Merged do
  subject { MyGroups::Merged.new(uid).get_feed[:groups] }

  context 'when not authenticated' do
    let(:uid) { nil }
    it {should eq([])}
  end

  context 'when multiple groups returned' do
    let(:uid) { rand(99999).to_s }
    before {MyGroups::Canvas.stub(:new).with(uid).and_return(double(fetch: [
      {name: 'qgroup', id: rand(9999).to_s, emitter: 'bCourses'}
    ]))}
    before {MyGroups::Callink.stub(:new).with(uid).and_return(double(fetch: [
      {name: 'young bears', id: rand(9999).to_s, emitter: 'CalLink'},
      {name: 'Old Bears', id: rand(9999).to_s, emitter: 'CalLink'}
    ]))}
    it 'sorts alphabetically' do
      names = subject.collect {|g| g[:name]}
      expect(names).to eq(['Old Bears', 'qgroup', 'young bears'])
    end
  end

end
