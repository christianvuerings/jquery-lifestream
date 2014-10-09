require "spec_helper"

describe Canvas::PublicAuthorizer do

  let(:uid)             { rand(99999).to_s }
  let(:canvas_user_id)  { '3323890' }

  subject { Canvas::PublicAuthorizer.new(canvas_user_id) }

  describe "#canvas_user_currently_teaching?" do

    # Note: This method serves a public interface, and must return an exact TRUE or FALSE value, not
    # a value that is interpretted as "truthy" (not nil or false), or falsey (nil, negative number, etc.)
    # The assertions below should not use be_falsey or be_truthy.
    # https://www.relishapp.com/rspec/rspec-expectations/v/2-2/docs/matchers/be-matchers

    before do
      allow_any_instance_of(Canvas::UserProfile).to receive(:login_id).and_return(uid)
      allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_create_canvas_course_site?).and_return(true)
    end

    context "when canvas user login id not present" do
      before { allow_any_instance_of(Canvas::UserProfile).to receive(:login_id).and_return(nil) }
      it 'returns false' do
        expect(subject.can_create_course_site?).to eq false
      end
    end

    context "when canvas user login id is present" do
      context "when user is not authorized to create course site" do
        before { allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_create_canvas_course_site?).and_return(false) }
        it 'returns false' do
          expect(subject.can_create_course_site?).to eq false
        end
      end

      context "when user is authorized to create course site" do
        it 'returns true' do
          expect(subject.can_create_course_site?).to eq true
        end
      end
    end

    context "when response is cached" do
      it "does not repeat requests to dependencies" do
        user_profile = double(:login_id => uid)
        expect(Canvas::UserProfile).to receive(:new).once.and_return(user_profile)
        expect(subject.can_create_course_site?).to eq true
        expect(subject.can_create_course_site?).to eq true
      end
    end
  end

end
