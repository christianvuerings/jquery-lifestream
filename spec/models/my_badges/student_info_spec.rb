describe 'MyBadges::StudentInfo' do

  let(:random_uid) { Time.now.to_f.to_s.gsub('.', '') }
  let(:default_name) { 'David Hasselhoff '}
  let(:student_info_instance) { MyBadges::StudentInfo.new(random_uid) }
  let(:fake_courses_proxy) {    CampusOracle::UserCourses.new({fake: true} ) }

  before(:each) do
    CampusOracle::UserAttributes.stub(:new).and_return(double(get_feed: {
      'person_name' => default_name,
      :roles => {
        :student => true,
        :exStudent => false,
        :faculty => false,
        :staff => false
      }
    }))
  end

  it 'should create student_info instance along with the necessary variables' do
    u = MyBadges::StudentInfo.new(random_uid)
    u.should_not be_nil
    u.is_a?(MyBadges::StudentInfo).should be_truthy
  end

  it 'should create a well-formed response with correct keys for a random user' do
    result = MyBadges::StudentInfo.new(random_uid).get
    result.has_key?(:californiaResidency).should be_truthy
    result.has_key?(:regStatus).should be_truthy
    result.has_key?(:regBlock).should be_truthy
    result.has_key?(:isLawStudent).should be_truthy
  end

  it 'should create camelCased regBlocks for oski' do
    result = MyBadges::StudentInfo.new('61889').get_reg_blocks
    result.has_key?(:needsAction).should be_truthy
    result.has_key?(:activeBlocks).should be_truthy
  end

  context 'term transitions' do
    let(:term_name) { 'Summer 2015' }
    before do
      allow(CampusOracle::UserAttributes).to receive(:new).and_return(double(get_feed: {reg_status: {transitionTerm: true}}))
      allow_any_instance_of(MyAcademics::TransitionTerm).to receive(:regstatus_feed).and_return({registered: is_registered, termName: term_name})
    end
    let(:result) { MyBadges::StudentInfo.new(random_uid).get }
    context 'registered during transition' do
      let(:is_registered) { true }
      it 'reports registration' do
        expect(result[:regStatus][:code]).to eq 'R'
        expect(result[:regStatus][:summary]).to eq 'Registered'
        expect(result[:regStatus][:explanation]).to eq 'You are officially registered for this term and are entitled to access campus services.'
        expect(result[:regStatus][:needsAction]).to eq false
      end
    end
    context 'not registered during transition' do
      let(:is_registered) { false }
      it 'reports not registered with no action required' do
        expect(result[:regStatus][:code]).to eq ' '
        expect(result[:regStatus][:summary]).to eq "Not registered for #{term_name}"
        expect(result[:regStatus][:explanation]).to be_nil
        expect(result[:regStatus][:needsAction]).to eq false
      end
    end
  end

  context 'for Law student users' do
    before { Bearfacts::Proxy.any_instance.stub(:lookup_student_id).and_return(99999997) }
    let! (:law_proxy) { Bearfacts::Profile.new({user_id: '212381', fake: true}) }
    before do
      Bearfacts::Profile.stub(:new).and_return(law_proxy)
      Bearfacts::Regblocks.stub(:new).and_return(double(get: {
        activeBlocks: [],
        inactiveBlocks: []
      }))
    end

    subject { MyBadges::StudentInfo.new('212381').get }

    it 'should set isLawStudent to true' do
      subject[:isLawStudent].should be_present
      subject[:isLawStudent].should be_truthy
    end
  end

  context 'offline bearfacts' do
    before do
      stub_request(:any, /.+bearfacts.*/).to_raise(Faraday::Error::ConnectionFailed)
      Bearfacts::Proxy.any_instance.stub(:lookup_student_id).and_return(11667051)
    end

    subject { MyBadges::StudentInfo.new(random_uid).get }

    it 'should have no active blocks' do
      subject[:regBlock].should be_present
      subject[:regBlock][:activeBlocks].should be_present
      subject[:regBlock][:activeBlocks].should eq(0)
    end

    it 'bearfacts API should be offline' do
      subject[:regBlock][:errored].should be_truthy
    end

    it 'needsAction should be false' do
      subject[:regBlock][:needsAction].should be_falsey
    end

    it 'should default isLawStudent to false' do
      subject[:isLawStudent].should be_falsey
    end
  end

  context 'valid bearfacts regblocks' do
    before { Bearfacts::Proxy.any_instance.stub(:lookup_student_id).and_return(11667051) }
    let! (:oski_profile_proxy) { Bearfacts::Profile.new({user_id: '61889', fake: true}) }
    let! (:oski_blocks_proxy) { Bearfacts::Regblocks.new({user_id: '61889', fake: true}) }
    before do
      Bearfacts::Profile.stub(:new).and_return(oski_profile_proxy)
      Bearfacts::Regblocks.stub(:new).and_return(oski_blocks_proxy)
    end

    subject { MyBadges::StudentInfo.new('61889').get }

    it 'should return some active_blocks' do
      subject[:regBlock].should be_present
      subject[:regBlock][:activeBlocks].should be_present
      subject[:regBlock][:activeBlocks].should > 0
    end

    it 'bearfacts API should be online' do
      subject[:regBlock][:errored].should be_falsey
    end

    it 'needsAction should be true' do
      subject[:regBlock][:needsAction].should be_truthy
    end

  end
end
