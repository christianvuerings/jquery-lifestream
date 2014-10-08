require "spec_helper"

describe Canvas::CanvasMediacasts do

  describe '#get_feed' do
    let(:canvas_course_id) { rand(99999) }
    let(:media_feed_empty) { JSON.parse(File.read(Rails.root.join('public/dummy/json/media_none.json'))) }
    let(:media_feed_full) { JSON.parse(File.read(Rails.root.join('public/dummy/json/media.json'))) }
    before do
      allow_any_instance_of(Canvas::CourseSections).to receive(:sections_list).and_return(
        double(body: canvas_course_sections_list.to_json, status: 200)
      )
    end
    subject { Canvas::CanvasMediacasts.new(course_id: canvas_course_id).get_feed }
    context 'when the Canvas course site maps to campus class sections' do
      let(:canvas_course_sections_list) do
        [
          {'id' => rand(99999).to_s, 'name' => 'a', 'course_id' => canvas_course_id, 'sis_section_id' => nil},
          {'id' => rand(99999).to_s, 'name' => 'b', 'course_id' => canvas_course_id, 'sis_section_id' => 'SEC:2013-B-7366'},
          {'id' => rand(99999).to_s, 'name' => 'c', 'course_id' => canvas_course_id, 'sis_section_id' => 'SEC:2012-B-16171'}
        ]
      end
      before do
        expect(Mediacasts::CourseMedia).to receive(:new).at_least(:once) do |yr, cd, dept, catid|
          expect((yr == '2013' && cd == 'B' && dept == 'BIOLOGY' && catid == '1A') ||
            (yr == '2012' && cd == 'B' && dept == 'COG SCI')).to be_truthy
          # 2013-B-7366
          if yr == '2013' && cd == 'B' && dept == 'BIOLOGY' && catid == '1A'
            double(get_feed: media_feed_empty)
          # 2012-B-16171
          elsif yr == '2012' && cd == 'B' && dept == 'COG SCI'
            double(get_feed: media_feed_full)
          end
        end
      end
      it { should eq media_feed_full }
    end
    context 'when the Canvas site does not map to any campus class sections' do
      let(:canvas_course_sections_list) do
        [
          {'id' => rand(99999).to_s, 'name' => 'a', 'course_id' => canvas_course_id, 'sis_section_id' => nil},
          {'id' => rand(99999).to_s, 'name' => 'b', 'course_id' => canvas_course_id, 'sis_section_id' => 'fuggidaboudit'}
        ]
      end
      it 'is empty' do
        expect(subject[:audio]).to be_blank
        expect(subject[:itunes][:audio]).to be_blank
        expect(subject[:itunes][:video]).to be_blank
      end
    end
  end

end
