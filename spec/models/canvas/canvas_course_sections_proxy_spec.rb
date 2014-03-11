require "spec_helper"

describe CanvasCourseSectionsProxy do

  let(:canvas_course_id)    { 767330 }
  subject                   { CanvasCourseSectionsProxy.new(:course_id => canvas_course_id) }

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

end
