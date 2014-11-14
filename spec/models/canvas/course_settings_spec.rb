require "spec_helper"

describe Canvas::CourseSettings do

  let(:canvas_course_id)    { '1121' }
  subject                   { Canvas::CourseSettings.new(:course_id => canvas_course_id) }

  context "when requesting course settings from canvas" do
    context "if course exists in canvas" do
      it "returns course settings hash" do
        settings = subject.settings
        expect(settings).to be_an_instance_of Hash
        expect(settings['allow_student_discussion_topics']).to eq true
        expect(settings['allow_student_forum_attachments']).to eq false
        expect(settings['allow_student_discussion_editing']).to eq true
        expect(settings['grading_standard_enabled']).to eq true
        expect(settings['grading_standard_id']).to eq 0
      end

      it "uses cache by default" do
        Canvas::CourseSettings.should_receive(:fetch_from_cache).and_return({:cached => 'hash'})
        settings = subject.settings
        expect(settings).to be_an_instance_of Hash
        expect(settings[:cached]).to eq 'hash'
      end

      it "bypasses cache when cache option is false" do
        Canvas::CourseSettings.should_not_receive(:fetch_from_cache)
        settings = subject.settings(:cache => false)
        expect(settings).to be_an_instance_of Hash
        expect(settings['allow_student_discussion_topics']).to eq true
      end
    end

    context "if course does not exist in canvas" do
      before { Canvas::CourseSettings.any_instance.should_receive(:request_uncached).and_return(nil) }
      it "returns nil" do
        settings = subject.settings
        expect(settings).to be_nil
      end
    end
  end

end
