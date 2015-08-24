describe CanvasLti::PublicAuthorizer do

  let(:uid)             { rand(99999).to_s }
  let(:canvas_user_id)  { '3323890' }

  subject { CanvasLti::PublicAuthorizer.new(canvas_user_id) }

  describe '#can_create_site?' do

    # Note: This method serves a public interface, and must return an exact TRUE or FALSE value, not
    # a value that is interpreted as "truthy" (not nil or false), or falsey (nil, negative number, etc.)
    # The assertions below should not use be_falsey or be_truthy.
    # https://www.relishapp.com/rspec/rspec-expectations/v/2-2/docs/matchers/be-matchers

    context 'when canvas user login id not present' do
      before { allow_any_instance_of(Canvas::UserProfile).to receive(:login_id).and_return(nil) }
      it 'returns false' do
        expect(subject.can_create_site?).to eq false
      end
    end

    context 'when canvas user login id is present' do
      before do
        allow_any_instance_of(Canvas::UserProfile).to receive(:login_id).and_return(uid)
        allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_create_canvas_project_site?).and_return(is_staff)
        allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_create_canvas_course_site?).and_return(is_teaching)
      end

      context 'when user is not authorized to create a project or a course site' do
        let(:is_staff) {false}
        let(:is_teaching) {false}
        it 'returns false' do
          expect(subject.can_create_site?).to eq false
        end
      end

      context 'when user is authorized to create a project but not a course site' do
        let(:is_staff) {true}
        let(:is_teaching) {false}
        it 'returns false' do
          expect(subject.can_create_site?).to eq true
        end
        it 'does not repeat requests when response is cached' do
          user_profile = double(:login_id => uid)
          expect(Canvas::UserProfile).to receive(:new).once.and_return(user_profile)
          expect(subject.can_create_site?).to eq true
          expect(subject.can_create_site?).to eq true
        end
      end

      context 'when user is authorized to create a course but not a project site' do
        let(:is_staff) {false}
        let(:is_teaching) {true}
        it 'returns false' do
          expect(subject.can_create_site?).to eq true
        end
      end

      context 'when user is authorized to create either type of site' do
        let(:is_staff) {true}
        let(:is_teaching) {true}
        it 'returns true' do
          expect(subject.can_create_site?).to eq true
        end
      end
    end
  end
end
