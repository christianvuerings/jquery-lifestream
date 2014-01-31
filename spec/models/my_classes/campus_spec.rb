require "spec_helper"

describe MyClasses::Campus do
  let(:user_id) {rand(99999).to_s}
  let(:ccn) {rand(9999)}
  let(:catid) {"#{rand(999)}B"}
  let(:course_id) {"econ-#{catid}-#{term_yr}-#{term_cd}"}
  let(:fake_campus) do
    {
      "#{term_yr}-#{term_cd}" => [{
        id: course_id,
        term_yr: term_yr,
        term_cd: term_cd,
        catid: catid,
        dept: 'ECON',
        course_code: "ECON #{catid}",
        emitter: 'Campus',
        name: "Retire in #{ccn} Years",
        role: 'Student',
        sections: [{
          ccn: ccn
        }]
      }]
    }
  end

  describe '#fetch' do
    before {CampusUserCoursesProxy.stub(:new).with(user_id: user_id).and_return(double(get_all_campus_courses: fake_campus))}
    subject { MyClasses::Campus.new(user_id).fetch }
    context 'when enrolled in a current class' do
      let(:term_yr) {CampusData.current_year}
      let(:term_cd) {CampusData.current_term}
      its(:size) {should eq 1}
      it 'includes class info' do
        class_info = subject[0]
        expect(class_info[:emitter]).to eq CampusUserCoursesProxy::APP_ID
        expect(class_info[:course_code]).to eq "ECON #{catid}"
        expect(class_info[:site_url].blank?).to be_false
        expect(class_info[:sections].first[:ccn]).to eq ccn
      end
    end
    context 'when enrolled in a non-current term' do
      let(:term_yr) {2012}
      let(:term_cd) {CampusData.current_term}
      its(:size) {should eq 0}
    end
  end

end
