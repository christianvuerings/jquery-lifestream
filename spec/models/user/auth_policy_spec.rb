require "spec_helper"

describe User::AuthPolicy do
  let(:user_id)       { rand(99999).to_s }
  let(:user)          { User::Auth.get(user_id) }
  let(:super_user)    { User::Auth.new(uid: user_id, is_superuser: true, is_test_user: false, is_author: false, is_viewer: false, active: true) }
  subject             { User::AuthPolicy.new(user, user) }

  # Note: The ApplicationController#current_user method returns User::Auth object used both as the user and record arguments to initialize User::AuthPolicy.

  describe "#can_administrate_globally?" do
    it "returns true when user is super user" do
      auth_policy = User::AuthPolicy.new(super_user, super_user)
      expect(auth_policy.can_administrate_globally?).to be_true
    end

    it "returns true when user is a canvas root account administrator" do
      canvas_admins = double()
      canvas_admins.stub(:admin_user?).and_return(true)
      Canvas::Admins.stub(:new).and_return(canvas_admins)
      expect(subject.can_administrate_globally?).to be_true
    end

    it "returns false is not a super user or canvas administrator" do
      expect(subject.can_administrate_globally?).to be_false
    end
  end

  describe "#can_administrate_canvas?" do
    it "returns true when user is a canvas root account administrator" do
      canvas_admins = double()
      canvas_admins.stub(:admin_user?).and_return(true)
      Canvas::Admins.stub(:new).and_return(canvas_admins)
      expect(subject.can_administrate_canvas?).to be_true
    end

    it "returns false when user is not a canvas root account administrator" do
      expect(subject.can_administrate_canvas?).to be_false
    end
  end

  describe "#can_create_canvas_course_site?" do
    subject { User::AuthPolicy.new(user, user).can_create_canvas_course_site? }
    before do
      User::AuthPolicy.any_instance.stub(:can_administrate?).and_return(false)
      User::AuthPolicy.any_instance.stub(:can_administrate_canvas?).and_return(false)
    end

    context "when user is not teaching courses in current or future semester" do
      before { allow_any_instance_of(Canvas::CurrentTeacher).to receive(:user_currently_teaching?).and_return(false) }
      it { should be_false }
    end

    context "when user is teaching courses in a current term" do
      before { allow_any_instance_of(Canvas::CurrentTeacher).to receive(:user_currently_teaching?).and_return(true) }
      it { should be_true }
    end

    context "when user is a canvas root account administrator" do
      before { User::AuthPolicy.any_instance.stub(:can_administrate_canvas?).and_return(true) }
      it { should be_true }
    end

    context "when user is a calcentral administrator" do
      before { User::AuthPolicy.any_instance.stub(:can_administrate?).and_return(true) }
      it { should be_true }
    end
  end

end
