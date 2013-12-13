require "spec_helper"

describe CanvasCourseUserProxy do

  let(:user_id)         { 4321321 }
  let(:course_id)    	  { 767330 }
  let(:canvas_course_user) do
    {
      'id' => 4321321,
      'name' => "Michael Steven OWEN",
      'sis_user_id' => 'UID:105431',
      'sis_login_id' => '105431',
      'login_id' => '105431',
      'enrollments' => [
        {'course_id' => 767330, 'course_section_id' => 1312468, 'id' => 20241907, 'type' => "TeacherEnrollment", 'role' => "StudentEnrollment"},
        {'course_id' => 767330, 'course_section_id' => 1312468, 'id' => 20241908, 'type' => "TeacherEnrollment", 'role' => "ObserverEnrollment"},
      ],
    }
  end

  subject               { CanvasCourseUserProxy.new(:user_id => user_id, :course_id => course_id) }

  context "when initializing" do
    it "raises exception if user id option not present" do
      expect { CanvasCourseUserProxy.new(:course_id => course_id) }.to raise_error(ArgumentError, "User ID option required")
    end

    it "raises exception if user id option is not an integer" do
      expect { CanvasCourseUserProxy.new(:user_id => "#{user_id}", :course_id => course_id) }.to raise_error(ArgumentError, "User ID option must be a Fixnum")
    end

    it "raises exception if course id option not present" do
      expect { CanvasCourseUserProxy.new(:user_id => user_id) }.to raise_error(ArgumentError, "Course ID option required")
    end

    it "raises exception if course id option is not an integer" do
      expect { CanvasCourseUserProxy.new(:user_id => user_id, :course_id => "#{course_id}") }.to raise_error(ArgumentError, "Course ID option must be a Fixnum")
    end
  end

  context "when requesting single course user from canvas" do
    context "if course user exists in canvas" do
      it "returns course user hash" do
        user = subject.course_user
        expect(user).to be_an_instance_of Hash
        expect(user['id']).to eq 4321321
        expect(user['name']).to eq "Michael Steven OWEN"
        expect(user['sis_user_id']).to eq "UID:105431"
        expect(user['sis_login_id']).to eq "105431"
        expect(user['login_id']).to eq "105431"
        expect(user['enrollments']).to be_an_instance_of Array
        expect(user['enrollments'].count).to eq 1
        expect(user['enrollments'][0]['course_id']).to eq 767330
        expect(user['enrollments'][0]['course_section_id']).to eq 1312468
        expect(user['enrollments'][0]['id']).to eq 20241907
        expect(user['enrollments'][0]['type']).to eq "StudentEnrollment"
        expect(user['enrollments'][0]['role']).to eq "StudentEnrollment"
      end

      it "uses cache by default" do
        CanvasCourseUserProxy.should_receive(:fetch_from_cache).and_return({})
        user = subject.course_user
        expect(user).to be_an_instance_of Hash
      end

      it "bypasses cache when cache option is false" do
        CanvasCourseUserProxy.should_not_receive(:fetch_from_cache)
        user = subject.course_user(:cache => false)
        expect(user).to be_an_instance_of Hash
        expect(user['id']).to eq 4321321
      end
    end

    context "if course user does not exist in canvas" do
      before { CanvasCourseUserProxy.any_instance.should_receive(:request_uncached).and_return(nil) }
      it "returns nil" do
        user = subject.course_user
        expect(user).to be_nil
      end
    end
  end

  context "when checking if user is course admin" do
    context "if canvas user argument is blank" do
      it "returns false" do
        expect(subject.class.is_course_admin?(nil)).to be_false
      end
    end

    context "if canvas user has no matching admin role" do
      it "returns false" do
        expect(subject.class.is_course_admin?(canvas_course_user)).to be_false
      end
    end

    context "if canvas user has teacher role" do
      before { canvas_course_user['enrollments'][1]['role'] = 'TeacherEnrollment' }
      it "returns true" do
        expect(subject.class.is_course_admin?(canvas_course_user)).to be_true
      end
    end

    context "if canvas user has teacher assistant role" do
      before { canvas_course_user['enrollments'][1]['role'] = 'TaEnrollment' }
      it "returns true" do
        expect(subject.class.is_course_admin?(canvas_course_user)).to be_true
      end
    end

    context "if canvas user has designer role" do
      before { canvas_course_user['enrollments'][1]['role'] = 'DesignerEnrollment' }
      it "returns true" do
        expect(subject.class.is_course_admin?(canvas_course_user)).to be_true
      end
    end
  end

end
