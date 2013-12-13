require "spec_helper"

describe CanvasSectionEnrollmentsProxy do

  let(:user_id)                   { 1234567 } # 4868640
  let(:canvas_section_id)         { 1311313 } # 1312468
  subject                         { CanvasSectionEnrollmentsProxy.new(:user_id => user_id, :section_id => canvas_section_id) }

  context "when initializing" do
    it "raises exception if section id option not present" do
      expect { CanvasSectionEnrollmentsProxy.new(:user_id => user_id) }.to raise_error(ArgumentError, "Section ID option required")
    end

    it "raises exception if section id option is not an integer" do
      expect { CanvasSectionEnrollmentsProxy.new(:user_id => user_id, :section_id => "#{canvas_section_id}") }.to raise_error(ArgumentError, "Section ID option must be a Fixnum")
    end
  end

  context "when enrolling user into canvas course section" do
    it "raises exception if user id is not an integer" do
      expect { subject.enroll_user('not_an_integer', 'TaEnrollment', 'active', false) }.to raise_error(ArgumentError, "User ID must be a Fixnum")
    end

    it "raises exception if enrollment type is not a string" do
      expect { subject.enroll_user(user_id, 1234, 'active', false) }.to raise_error(ArgumentError, "Enrollment type must be a String")
    end

    it "raises exception if enrollment state is not a string" do
      expect { subject.enroll_user(user_id, 'TaEnrollment', 1234, false) }.to raise_error(ArgumentError, "Enrollment state must be a String")
    end

    it "raises exception if notification flag is not true or false" do
      expect { subject.enroll_user(user_id, 'TaEnrollment', 'active', 'not true or false') }.to raise_error(ArgumentError, "Notification flag must be a Boolean")
      expect { subject.enroll_user(user_id, 'TaEnrollment', 'active', 0) }.to raise_error(ArgumentError, "Notification flag must be a Boolean")
      expect { subject.enroll_user(user_id, 'TaEnrollment', 'active', 1) }.to raise_error(ArgumentError, "Notification flag must be a Boolean")
    end

    it "raises exception if enrollment type string is not valid" do
      expect { subject.enroll_user(user_id, 'AssistantEnrollment', 'active', false) }.to raise_error(ArgumentError, "Enrollment type argument 'AssistantEnrollment', must be StudentEnrollment, TeacherEnrollment, TaEnrollment, ObserverEnrollment, or DesignerEnrollment")
    end

    it "raises exception if enrollment state is not valid" do
      expect { subject.enroll_user(user_id, 'TaEnrollment', 'inactive', false) }.to raise_error(ArgumentError, "Enrollment state argument 'inactive', must be active or invited")
    end

    it "returns confirmation of enrollment" do
      response = subject.enroll_user(user_id, 'TaEnrollment', 'active', false)
      expect(response).to be_an_instance_of Hash
      expect(response['id']).to eq 20618200
      expect(response['user_id']).to eq 1234567
      expect(response['course_id']).to eq 1161161
      expect(response['course_section_id']).to eq 1311313
      expect(response['enrollment_state']).to eq 'active'
      expect(response['role']).to eq 'TaEnrollment'
    end
  end

end
