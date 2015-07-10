require 'spec_helper'

describe Canvas::CourseSettings do

  let(:canvas_course_id)    { '1121' }
  subject                   { Canvas::CourseSettings.new(:course_id => canvas_course_id) }

  context 'when requesting course settings from canvas' do
    context 'if course exists in canvas' do
      it 'returns course settings hash' do
        settings = subject.settings
        expect(settings).to be_an_instance_of Hash
        expect(settings['allow_student_discussion_topics']).to eq true
        expect(settings['allow_student_forum_attachments']).to eq false
        expect(settings['allow_student_discussion_editing']).to eq true
        expect(settings['grading_standard_enabled']).to eq true
        expect(settings['grading_standard_id']).to eq 0
      end

      it 'uses cache by default' do
        Canvas::CourseSettings.should_receive(:fetch_from_cache).and_return({:cached => 'hash'})
        settings = subject.settings
        expect(settings).to be_an_instance_of Hash
        expect(settings[:cached]).to eq 'hash'
      end

      it 'bypasses cache when cache option is false' do
        Canvas::CourseSettings.should_not_receive(:fetch_from_cache)
        settings = subject.settings(:cache => false)
        expect(settings).to be_an_instance_of Hash
        expect(settings['allow_student_discussion_topics']).to eq true
      end
    end

    context 'when setting grading scheme' do
      let(:request_options) {
        {
          :method => :put,
          :body => {
            'course' => {
              'grading_standard_id' => Settings.canvas_proxy.default_grading_scheme_id.to_i
            }
          },
        }
      }
      let(:fake_json_body) { {'id' => 1121, 'name' => 'Just another course site'}.to_json }
      let(:fake_response) {
        fake_response = double()
        allow(fake_response).to receive(:body).and_return(fake_json_body)
        fake_response
      }
      it 'sets ucberkeley preferred default scheme by default' do
        course = subject.set_grading_scheme
        expect(course).to be_an_instance_of Hash
        expect(course['id']).to eq 1121
        expect(course['course_code']).to eq 'COMPSCI 9C - LEC 001'
        expect(course['name']).to eq '001-Ruby for Programmers'
      end

      it 'sets specified grading scheme for course site' do
        request_options[:body]['course']['grading_standard_id'] = 123456
        expect(subject).to receive(:request_uncached).with("courses/#{canvas_course_id}", request_options).and_return(fake_response)
        course = subject.set_grading_scheme(123456)
        expect(course).to be_an_instance_of Hash
        expect(course['name']).to eq 'Just another course site'
      end
    end

    context 'if course does not exist in canvas' do
      before { Canvas::CourseSettings.any_instance.should_receive(:request_uncached).and_return(nil) }
      it 'returns nil' do
        settings = subject.settings
        expect(settings).to be_nil
      end
    end
  end

end
