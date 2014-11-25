require "spec_helper"

describe Canvas::CourseSections do

  let(:canvas_course_id)    { 767330 }
  subject                   { Canvas::CourseSections.new(:course_id => canvas_course_id) }

  it "provides sections list" do
    response = subject.sections_list
    sections = JSON.parse(response.body)
    expect(sections).to be_an_instance_of Array
    expect(sections.count).to eq 2
    expect(sections[0]['id']).to eq 1237012
    expect(sections[0]['name']).to eq "Canvas-only Section"
    expect(sections[0]['course_id']).to eq 767330
    expect(sections[0]['sis_section_id']).to be_nil
    expect(sections[1]['id']).to eq 1237009
    expect(sections[1]['name']).to eq "2013-C-7309"
    expect(sections[1]['course_id']).to eq 767330
    expect(sections[1]['sis_section_id']).to eq "SEC:2013-C-7309"
  end

  context "when providing official section identifiers existing within course" do
    let(:course_sections) { [{'sis_section_id' => 'SEC:2014-C-7309'}, {'sis_section_id' => 'SEC:2014-C-6211'}] }
    let(:failed_response) { double('course sections response', :status => 500, :body => '') }
    let(:success_response) { double('course sections response', :status => 200, :body => JSON.generate(course_sections))}

    context "when course sections request fails" do
      before { allow(subject).to receive(:sections_list).and_return(failed_response) }
      it "returns empty array" do
        expect(subject.official_section_identifiers).to eq []
      end
    end

    context "when course sections request returns sections" do
      before { allow(subject).to receive(:sections_list).and_return(success_response) }
      it "returns ccn and term for canvas course sections" do
        sis_section_ids = subject.official_section_identifiers
        expect(sis_section_ids).to be_an_instance_of Array
        expect(sis_section_ids.count).to eq 2
        expect(sis_section_ids[0]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '7309'})
        expect(sis_section_ids[1]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '6211'})
      end

      context "when course sections returned includes invalid section ids" do
        let(:course_sections) { [{'sis_section_id' => 'SEC:2014-C-7309'}, {'sis_section_id' => nil}, {'sis_section_id' => 'SEC:2014-C-6211'}, {'sis_section_id' => '2014-C-3623'}] }
        it "filters out invalid section ids" do
          sis_section_ids = subject.official_section_identifiers
          expect(sis_section_ids).to be_an_instance_of Array
          expect(sis_section_ids.count).to eq 2
          expect(sis_section_ids[0]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '7309'})
          expect(sis_section_ids[1]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '6211'})
        end
      end

    end
  end

end
