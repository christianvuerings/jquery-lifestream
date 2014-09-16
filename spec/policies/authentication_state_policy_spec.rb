require "spec_helper"

describe AuthenticationStatePolicy do
  let(:session_state) do
    {user_id: user_id, original_user_id: original_user_id, lti_authenticated_only: lti_authenticated_only}
  end
  let(:original_user_id) {nil}
  let(:lti_authenticated_only) {nil}
  let(:superuser_uid) {random_id}
  let(:author_uid) {random_id}
  let(:viewer_uid) {random_id}
  let(:average_joe_uid) {random_id}
  let(:inactive_superuser_uid) {random_id}
  let(:auth_map) do
    {
      superuser_uid => {uid: superuser_uid, is_superuser: true, is_author: false, is_viewer: false, active: true},
      author_uid => {uid: author_uid, is_superuser: false, is_author: true, is_viewer: false, active: true},
      viewer_uid => {uid: viewer_uid, is_superuser: false, is_author: false, is_viewer: true, active: true},
      average_joe_uid => {uid: average_joe_uid, is_superuser: false, is_author: false, is_viewer: false, active: true},
      inactive_superuser_uid => {uid: inactive_superuser_uid, is_superuser: true, is_author: false, is_viewer: false, active: false}
    }
  end
  before do
    allow(User::Auth).to receive(:get) do |uid|
      User::Auth.new(auth_map[uid])
    end
  end

  subject { AuthenticationState.new(session_state).policy }

  describe '#access_google?' do
    context 'as self' do
      let(:user_id) {average_joe_uid}
      its(:access_google?) { should be_true }
    end
    context 'as someone else' do
      let(:user_id) {superuser_uid}
      let(:original_user_id) {viewer_uid}
      its(:access_google?) { should be_false }
    end
    context 'in embedded app' do
      let(:user_id) {superuser_uid}
      let(:lti_authenticated_only) {true}
      its(:access_google?) { should be_false }
    end
  end

  describe '#can_administrate?' do
    context 'superuser as self' do
      let(:user_id) {superuser_uid}
      its(:can_administrate?) { should be_true }
    end
    context 'inactive superuser' do
      let(:user_id) {inactive_superuser_uid}
      its(:can_administrate?) { should be_false }
    end
    context 'viewer as self' do
      let(:user_id) {viewer_uid}
      its(:can_administrate?) { should be_false }
    end
    context 'author as self' do
      let(:user_id) {author_uid}
      its(:can_administrate?) { should be_false }
    end
    context 'superuser as someone else' do
      let(:user_id) {average_joe_uid}
      let(:original_user_id) {superuser_uid}
      its(:can_administrate?) { should be_false }
    end
    context 'viewing as superuser' do
      let(:user_id) {superuser_uid}
      let(:original_user_id) {viewer_uid}
      its(:can_administrate?) { should be_false }
    end
    context 'in embedded app' do
      let(:user_id) {superuser_uid}
      let(:lti_authenticated_only) {true}
      its(:can_administrate?) { should be_false }
    end
  end

  describe '#can_author?' do
    context 'superuser as self' do
      let(:user_id) {superuser_uid}
      its(:can_author?) { should be_true }
    end
    context 'inactive superuser' do
      let(:user_id) {inactive_superuser_uid}
      its(:can_author?) { should be_false }
    end
    context 'viewer as self' do
      let(:user_id) {viewer_uid}
      its(:can_author?) { should be_false }
    end
    context 'author as self' do
      let(:user_id) {author_uid}
      its(:can_author?) { should be_true }
    end
    context 'in embedded app' do
      let(:user_id) {author_uid}
      let(:lti_authenticated_only) {true}
      its(:can_author?) { should be_false }
    end
  end

  describe '#can_view_as?' do
    context 'superuser as self' do
      let(:user_id) {superuser_uid}
      its(:can_view_as?) { should be_true }
    end
    context 'inactive superuser' do
      let(:user_id) {inactive_superuser_uid}
      its(:can_view_as?) { should be_false }
    end
    context 'viewer as self' do
      let(:user_id) {viewer_uid}
      its(:can_view_as?) { should be_true }
    end
    context 'author as self' do
      let(:user_id) {author_uid}
      its(:can_view_as?) { should be_false }
    end
    # This is a little quirky, but we want to allow easy view-as switching even while mimicking
    # someone else.
    context 'viewer as someone else' do
      let(:user_id) {average_joe_uid}
      let(:original_user_id) {viewer_uid}
      its(:can_view_as?) { should be_true }
    end
    context 'in embedded app' do
      let(:user_id) {viewer_uid}
      let(:lti_authenticated_only) {true}
      its(:can_view_as?) { should be_false }
    end
  end

  describe '#can_administrate_canvas?' do
    let(:user_id) {average_joe_uid}
    it 'returns true when user is a canvas root account administrator' do
      allow(Canvas::Admins).to receive(:new).and_return(double(admin_user?: true))
      expect(subject.can_administrate_canvas?).to be_true
    end
    it 'returns false when user is not a canvas root account administrator' do
      expect(subject.can_administrate_canvas?).to be_false
    end
  end

  describe '#can_create_canvas_course_site?' do
    let(:user_id) {average_joe_uid}
    subject { AuthenticationState.new(session_state).policy.can_create_canvas_course_site? }
    context 'when user is not teaching courses in current or future semester' do
      before { allow_any_instance_of(Canvas::CurrentTeacher).to receive(:user_currently_teaching?).and_return(false) }
      it { should be_false }
    end
    context 'when user is teaching courses in a current term' do
      before { allow_any_instance_of(Canvas::CurrentTeacher).to receive(:user_currently_teaching?).and_return(true) }
      it { should be_true }
    end
    context 'when user is a canvas root account administrator' do
      before { allow(Canvas::Admins).to receive(:new).and_return(double(admin_user?: true)) }
      it { should be_true }
    end
    context 'when user is a calcentral administrator' do
      let(:user_id) {superuser_uid}
      it { should be_true }
    end
  end

end
